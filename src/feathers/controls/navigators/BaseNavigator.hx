/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.core.FeathersControl;
import feathers.core.IFocusContainer;
import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.events.TransitionEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.Measurements;
import feathers.motion.effects.IEffectContext;
import feathers.motion.effects.NoOpEffectContext;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.geom.Point;

/**
	Base class for navigator components.

	@event openfl.events.Event.CLEAR Dispatched when the
	`BaseNavigator.activeItemView` and `BaseNavigator.activeItemID` are cleared.

	@event openfl.events.Event.CHANGE Dispatched when the
	`BaseNavigator.activeItemView` and `BaseNavigator.activeItemID` are changed.

	@event feathers.events.TransitionEvent.TRANSITION_START Dispatched at the
	beginning of a transition.

	@event feathers.events.TransitionEvent.TRANSITION_COMPLETE Dispatched at the
	end of a transition.

	@event feathers.events.TransitionEvent.TRANSITION_CANCEL Dispatched when a
	transition is cancelled without completing.

	@since 1.0.0
**/
@:event(openfl.events.Event.CLEAR)
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.TransitionEvent.TRANSITION_START)
@:event(feathers.events.TransitionEvent.TRANSITION_COMPLETE)
@:event(feathers.events.TransitionEvent.TRANSITION_CANCEL)
class BaseNavigator extends FeathersControl implements IFocusContainer {
	private static function defaultTransition(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
		return new NoOpEffectContext(oldView);
	}

	private function new() {
		super();
		this._viewsContainer = this;
		this.addEventListener(Event.ADDED_TO_STAGE, baseNavigator_addedToStageHandler);
	}

	private var _activeItemID:String;

	/**
		The string identifier for the currently active item, or `null` if
		there is no active item.

		@since 1.0.0
	**/
	public var activeItemID(get, never):String;

	private function get_activeItemID():String {
		return this._activeItemID;
	}

	private var _activeItemView:DisplayObject;

	/**
		A reference to the currently active item's view, or `null` if there is
		no active item.

		@since 1.0.0
	**/
	public var activeItemView(get, never):DisplayObject;

	private function get_activeItemView():DisplayObject {
		return this._activeItemView;
	}

	private var _transitionActive:Bool;

	/**
		Indicates whether the navigator is currently transitioning between
		views or not.

		@since 1.0.0
	**/
	public var transitionActive(get, never):Bool;

	private function get_transitionActive():Bool {
		return this._transitionActive;
	}

	@:getter(tabEnabled)
	override private function get_tabEnabled():Bool {
		return false;
	}

	private var _childFocusEnabled:Bool = true;

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	public var childFocusEnabled(get, set):Bool;

	private function get_childFocusEnabled():Bool {
		return this._enabled && !this._transitionActive && this._childFocusEnabled;
	}

	private function set_childFocusEnabled(value:Bool):Bool {
		if (this._childFocusEnabled == value) {
			return this._childFocusEnabled;
		}
		this._childFocusEnabled = value;
		return this._childFocusEnabled;
	}

	private var _viewsContainer:DisplayObjectContainer;
	private var _activeViewMeasurements:Measurements = new Measurements();
	private var _addedItemIDs:Array<String> = [];
	private var _addedItems:Map<String, Dynamic> = new Map();
	private var _previousViewInTransition:DisplayObject;
	private var _previousViewInTransitionID:String;
	private var _nextViewInTransition:DisplayObject;
	private var _nextViewInTransitionID:String;
	private var _pendingItemID:String;
	private var _pendingItemTransition:(DisplayObject, DisplayObject) -> IEffectContext;
	private var _clearAfterTransition:Bool = false;
	private var _delayedTransition:(DisplayObject, DisplayObject) -> IEffectContext;
	private var _waitingForDelayedTransition:Bool = false;
	private var _waitingTransition:(DisplayObject, DisplayObject) -> IEffectContext;
	private var _waitingForTransitionFrameCount:Int = 0;

	private var _autoSizeMode:AutoSizeMode = STAGE;

	/**
		Determines how the navigator will set its own size when its dimensions
		(width and height) aren't set explicitly.

		In the following example, the navigator will be sized to match its
		content:

		```haxe
		navigator.autoSizeMode = CONTENT;
		```

		@default `feathers.controls.AutoSizeMode.STAGE`

		@see `feathers.controls.AutoSizeMode.STAGE`
		@see `feathers.controls.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	public var autoSizeMode(get, set):AutoSizeMode;

	private function get_autoSizeMode():AutoSizeMode {
		return this._autoSizeMode;
	}

	private function set_autoSizeMode(value:AutoSizeMode):AutoSizeMode {
		if (this._autoSizeMode == value) {
			return this._autoSizeMode;
		}
		this._autoSizeMode = value;
		this.setInvalid(SIZE);
		if (this._activeItemView != null) {
			if (this._autoSizeMode == STAGE) {
				this._activeItemView.removeEventListener(Event.RESIZE, activeItemView_resizeHandler);
			} else // content
			{
				this._activeItemView.addEventListener(Event.RESIZE, activeItemView_resizeHandler);
			}
		}
		if (this.stage != null) {
			if (this._autoSizeMode == STAGE) {
				this.stage.addEventListener(Event.RESIZE, baseNavigator_stage_resizeHandler);
				this.addEventListener(Event.REMOVED_FROM_STAGE, baseNavigator_removedFromStageHandler);
			} else // content
			{
				this.stage.removeEventListener(Event.RESIZE, baseNavigator_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, baseNavigator_removedFromStageHandler);
			}
		}
		return this._autoSizeMode;
	}

	private var topContentOffset:Float = 0.0;
	private var rightContentOffset:Float = 0.0;
	private var bottomContentOffset:Float = 0.0;
	private var leftContentOffset:Float = 0.0;

	/**
		Removes all items that were added with `addItem()`.

		@since 1.0.0
	**/
	public function removeAllItems():Void {
		if (this._transitionActive) {
			throw new IllegalOperationError("Cannot remove all items while a transition is active.");
		}
		if (this._activeItemView != null) {
			// if someone meant to have a transition, they would have called
			// clearActiveItem() first
			this.clearActiveItemInternal(null);
			FeathersEvent.dispatch(this, Event.CLEAR);
		}
		this._addedItems.clear();
		#if hl
		this._addedItemIDs.splice(0, this._addedItemIDs.length);
		#else
		this._addedItemIDs.resize(0);
		#end
	}

	/**
		Determines if an item with the specified identifier has been added with
		`addItem()`.

		@since 1.0.0
	**/
	public function hasItem(id:String):Bool {
		return this._addedItems.exists(id);
	}

	/**
		Returns a list of all item identifiers that have been added with
		`addItem()`.

		@since 1.0.0
	**/
	public function getItemIDs(?result:Array<String>):Array<String> {
		if (result == null) {
			result = [];
		}
		for (id in this._addedItems.keys()) {
			result.push(id);
		}
		return result;
	}

	override private function update():Void {
		var sizeInvalid = this.isInvalid(SIZE);

		this.topContentOffset = 0.0;
		this.rightContentOffset = 0.0;
		this.bottomContentOffset = 0.0;
		this.leftContentOffset = 0.0;
		sizeInvalid = this.measure() || sizeInvalid;
		this.layoutContent();
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var needsToMeasureContent = this._autoSizeMode == CONTENT || this.stage == null;
		var stageWidth:Float = 0.0;
		var stageHeight:Float = 0.0;
		if (!needsToMeasureContent) {
			// TODO: see if this can be done without allocations
			var topLeft = this.globalToLocal(new Point());
			var bottomRight = this.globalToLocal(new Point(this.stage.stageWidth, this.stage.stageHeight));
			stageWidth = bottomRight.x - topLeft.x;
			stageHeight = bottomRight.y - topLeft.y;
		}

		var measureView:IMeasureObject = null;
		if ((this._activeItemView is IMeasureObject)) {
			measureView = cast(this._activeItemView, IMeasureObject);
		}

		if (this._activeItemView != null) {
			if (needsToMeasureContent) {
				MeasurementsUtil.resetFluidlyWithParent(this._activeViewMeasurements, this._activeItemView, this);
			}
			// optimization: pass down explicit width and height to active view
			// as soon as possible to avoid expensive validation measurement
			if (!needsWidth && this._activeItemView.width != this.explicitWidth) {
				this._activeItemView.width = this.explicitWidth;
			} else if (!needsToMeasureContent && this._activeItemView.width != stageWidth) {
				this._activeItemView.width = stageWidth;
			}
			if (!needsHeight && this._activeItemView.height != this.explicitHeight) {
				this._activeItemView.height = this.explicitHeight;
			} else if (!needsToMeasureContent && this._activeItemView.height != stageHeight) {
				this._activeItemView.height = stageHeight;
			}
		}

		if ((this._activeItemView is IValidating)) {
			cast(this._activeItemView, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (needsToMeasureContent) {
				if (this._activeItemView != null) {
					newWidth = this._activeItemView.width;
				} else {
					newWidth = 0.0;
				}
				newWidth += this.rightContentOffset + this.leftContentOffset;
			} else {
				newWidth = stageWidth;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (needsToMeasureContent) {
				if (this._activeItemView != null) {
					newHeight = this._activeItemView.height;
				} else {
					newHeight = 0.0;
				}
				newHeight += this.topContentOffset + this.bottomContentOffset;
			} else {
				newHeight = stageHeight;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (needsToMeasureContent) {
				if (measureView != null) {
					newMinWidth = measureView.minWidth;
				} else if (this._activeItemView != null) {
					newMinWidth = this._activeItemView.width;
				} else {
					newMinWidth = 0.0;
				}
				newMinWidth += this.rightContentOffset + this.leftContentOffset;
			} else {
				newMinWidth = stageWidth;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (needsToMeasureContent) {
				if (measureView != null) {
					newMinHeight = measureView.minHeight;
				} else if (this._activeItemView != null) {
					newMinHeight = this._activeItemView.height;
				} else {
					newMinHeight = 0.0;
				}
				newMinHeight += this.topContentOffset + this.bottomContentOffset;
			} else {
				newMinHeight = stageHeight;
			}
		}

		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (needsToMeasureContent) {
				if (measureView != null) {
					newMaxWidth = measureView.maxWidth;
				} else if (this._activeItemView != null) {
					newMaxWidth = this._activeItemView.width;
				} else {
					newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
				}
				newMaxWidth += this.rightContentOffset + this.leftContentOffset;
			} else {
				newMaxWidth = stageWidth;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (needsToMeasureContent) {
				if (measureView != null) {
					newMaxHeight = measureView.maxHeight;
				} else if (this._activeItemView != null) {
					newMaxHeight = this._activeItemView.height;
				} else {
					newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
				}
				newMaxHeight += this.topContentOffset + this.bottomContentOffset;
			} else {
				newMaxHeight = stageHeight;
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutContent():Void {
		if (this._activeItemView != null) {
			this._activeItemView.x = 0.0;
			this._activeItemView.y = 0.0;
			// don't set the width or height explicitly unless necessary because if
			// our explicit dimensions are cleared later, the measurement may not be
			// accurate anymore
			if (this._activeItemView.width != this.actualWidth) {
				this._activeItemView.width = this.actualWidth;
			}
			if (this._activeItemView.height != this.actualHeight) {
				this._activeItemView.height = this.actualHeight;
			}
			if ((this._activeItemView is IValidating)) {
				cast(this._activeItemView, IValidating).validateNow();
			}
		}
		if (this._nextViewInTransition != null) {
			this._nextViewInTransition.x = 0.0;
			this._nextViewInTransition.y = 0.0;
			if (this._nextViewInTransition.width != this.actualWidth) {
				this._nextViewInTransition.width = this.actualWidth;
			}
			if (this._nextViewInTransition.height != this.actualHeight) {
				this._nextViewInTransition.height = this.actualHeight;
			}
			if ((this._nextViewInTransition is IValidating)) {
				cast(this._nextViewInTransition, IValidating).validateNow();
			}
		}
		if (this._viewsContainer != this && (this._viewsContainer is IValidating)) {
			cast(this._viewsContainer, IValidating).validateNow();
		}
	}

	/**
		To be overridden by subclasses to create a view for the active item.

		@since 1.0.0
	**/
	@:dox(show)
	private function getView(id:String):DisplayObject {
		throw new IllegalOperationError("Missing override of BaseNavigator.getView()");
	}

	/**
		To be overridden by subclasses to clean up a view

		@since 1.0.0
	**/
	@:dox(show)
	private function disposeView(id:String, view:DisplayObject):Void {
		throw new IllegalOperationError("Missing override of BaseNavigator.disposeView()");
	}

	/**
		To be optionally overridden by subclasses to handle a completed
		transition.

		@since 1.0.0
	**/
	@:dox(show)
	private function transitionComplete():Void {}

	/**
		To be optionally overridden by subclasses to handle a completed
		transition.

		@since 1.0.0
	**/
	@:dox(show)
	private function transitionCancel():Void {}

	private function addItemInternal(id:String, item:Dynamic):Void {
		if (this._addedItems.exists(id)) {
			throw new ArgumentError('Item with id \'$id\' already defined. Cannot add two items with the same id.');
		}
		this._addedItems.set(id, item);
		this._addedItemIDs.push(id);
	}

	private function removeItemInternal(id:String):Dynamic {
		if (!this._addedItems.exists(id)) {
			throw new ArgumentError('Item with id \'$id\' cannot be removed because this id has not been added.');
		}
		if (this._transitionActive && (id == this._previousViewInTransitionID || id == this._activeItemID)) {
			throw new IllegalOperationError("Cannot remove an item while it is transitioning in or out.");
		}
		if (id == this._activeItemID) {
			// if someone meant to have a transition, they would have called
			// clearActiveItem()
			this.clearActiveItemInternal(null);
			FeathersEvent.dispatch(this, Event.CLEAR);
		}
		var item = this._addedItems.get(id);
		this._addedItems.remove(id);
		this._addedItemIDs.remove(id);
		return item;
	}

	private function clearFocusFromPreviousView():Void {
		if (this._previousViewInTransition == null) {
			return;
		}

		if (this._focusManager != null) {
			if (this._focusManager.focus == null) {
				return;
			}
			if ((this._previousViewInTransition is IFocusObject)
				&& this._focusManager.focus == cast(this._previousViewInTransition, IFocusObject)) {
				this._focusManager.focus = null;
			} else if ((this._previousViewInTransition is DisplayObjectContainer)
				&& cast(this._previousViewInTransition, DisplayObjectContainer).contains(cast(this._focusManager.focus, DisplayObject))) {
				this._focusManager.focus = null;
			}
		}

		if (this.stage.focus == null) {
			return;
		}
		if (this.stage.focus == this._previousViewInTransition
			|| ((this._previousViewInTransition is DisplayObjectContainer)
				&& cast(this._previousViewInTransition, DisplayObjectContainer).contains(this.stage.focus))) {
			this.stage.focus = this.stage;
		}
	}

	private function showItemInternal(id:String, transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (!this.hasItem(id)) {
			throw new ArgumentError('Item with id \'$id\' cannot be displayed because this id has not been added.');
		}
		if (this._transitionActive) {
			this._pendingItemID = id;
			this._pendingItemTransition = transition;
			this._clearAfterTransition = false;
			return null;
		}

		this._previousViewInTransition = this._activeItemView;
		this._previousViewInTransitionID = this._activeItemID;

		this.clearFocusFromPreviousView();

		this._transitionActive = true;

		var item = this._addedItems.get(id);
		this._nextViewInTransition = this.getView(id);
		if (this._nextViewInTransition == null) {
			throw new IllegalOperationError('Failed to display navigator item with id \'$id\'. Call to getView() incorrectly returned null.');
		}
		this._nextViewInTransitionID = id;
		if (this._autoSizeMode == CONTENT || this.stage == null) {
			this._nextViewInTransition.addEventListener(Event.RESIZE, activeItemView_resizeHandler);
		}
		var sameInstance = this._previousViewInTransition == this._nextViewInTransition;
		this._viewsContainer.addChild(this._nextViewInTransition);
		if ((this._nextViewInTransition is IUIControl)) {
			// initialize so that we can save the measurements
			cast(this._nextViewInTransition, IUIControl).initializeNow();
		}

		this.setInvalid(SELECTION);
		if (this._validationQueue != null && this._validationQueue.validating) {
			// force a completion validation of everything on the stage, but
			// only if we're not already doing that.
			// this makes the transition more smooth because it can prevent
			// garbage collection and other things happening during the
			// transition.
			this._validationQueue.validateNow();
		} else if (!this._validating) {
			this.validateNow();
		}

		if (sameInstance) {
			// we can't transition if both view are the same display object, so
			// so skip the transition!
			this._activeItemView = this._nextViewInTransition;
			this._activeItemID = this._nextViewInTransitionID;
			this._activeViewMeasurements.save(this._activeItemView);
			this._previousViewInTransition = null;
			this._previousViewInTransitionID = null;
			this._nextViewInTransition = null;
			this._nextViewInTransitionID = null;
			this._transitionActive = false;
			FeathersEvent.dispatch(this, Event.CHANGE);
		} else {
			this.startTransition(transition);
		}
		return this._activeItemView;
	}

	private function clearActiveItemInternal(?transition:(DisplayObject, DisplayObject) -> IEffectContext):Void {
		if (this._activeItemView == null) {
			// nothing to clear
			return;
		}

		if (this._transitionActive) {
			this._pendingItemID = null;
			this._pendingItemTransition = transition;
			this._clearAfterTransition = true;
			return;
		}

		this.clearFocusFromPreviousView();

		this._transitionActive = true;

		this._previousViewInTransition = this._activeItemView;
		this._previousViewInTransitionID = this._activeItemID;
		this._nextViewInTransition = null;
		this._nextViewInTransitionID = null;

		this.setInvalid(SELECTION);

		this.startTransition(transition);
	}

	private function startTransition(transition:(DisplayObject, DisplayObject) -> IEffectContext):Void {
		TransitionEvent.dispatch(this, TransitionEvent.TRANSITION_START, this._previousViewInTransitionID, this._previousViewInTransition,
			this._nextViewInTransitionID, this._nextViewInTransition);
		if (transition != null && transition != defaultTransition) {
			if (this._nextViewInTransition != null) {
				// temporarily make the active view invisible because the
				// transition doesn't start right away.
				this._nextViewInTransition.visible = false;
			}
			this._waitingForTransitionFrameCount = 0;
			this._waitingTransition = transition;

			// this is a workaround for an issue with transition performance.
			// see the comment in the listener for details.
			this.addEventListener(Event.ENTER_FRAME, baseNavigator_transitionWait_enterFrameHandler);
		} else {
			if (this._nextViewInTransition != null) {
				// the view may have been hidden if the transition was delayed
				this._nextViewInTransition.visible = true;
			}
			var transitionContext = defaultTransition(this._previousViewInTransition, this._nextViewInTransition);
			transitionContext.addEventListener(Event.COMPLETE, transition_completeHandler);
			transitionContext.addEventListener(Event.CANCEL, transition_cancelHandler);
			transitionContext.play();
		}
	}

	private function startWaitingTransition():Void {
		this.removeEventListener(Event.ENTER_FRAME, baseNavigator_transitionWait_enterFrameHandler);
		if (this._nextViewInTransition != null) {
			// this view may have been hidden while we were waiting to start the
			// transition
			this._nextViewInTransition.visible = true;
		}

		var transition = this._waitingTransition;
		this._waitingTransition = null;
		var transitionContext = transition(this._previousViewInTransition, this._nextViewInTransition);
		transitionContext.addEventListener(Event.COMPLETE, transition_completeHandler);
		transitionContext.addEventListener(Event.CANCEL, transition_cancelHandler);
		transitionContext.play();
	}

	private function baseNavigator_addedToStageHandler(event:Event):Void {
		if (this._autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(SIZE);
			this.stage.addEventListener(Event.RESIZE, baseNavigator_stage_resizeHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, baseNavigator_removedFromStageHandler);
		}
	}

	private function baseNavigator_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, baseNavigator_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, baseNavigator_stage_resizeHandler);
	}

	private function baseNavigator_transitionWait_enterFrameHandler(event:Event):Void {
		// we need to wait a couple of frames before we can start the
		// transition to make it as smooth as possible. this feels a little
		// hacky, to be honest, but I can't figure out why waiting only one
		// frame won't do the trick. the delay is so small though that it's
		// virtually impossible to notice.
		if (this._waitingForTransitionFrameCount < 2) {
			this._waitingForTransitionFrameCount++;
			return;
		}
		this.startWaitingTransition();
	}

	private function baseNavigator_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function activeItemView_resizeHandler(event:Event):Void {
		if (this._validating || this._autoSizeMode != CONTENT) {
			return;
		}
		this.setInvalid(SIZE);
	}

	private function transition_completeHandler(event:Event):Void {
		// consider the transition still active if something is already
		// queued up to happen next. if an event listener asks to show a new
		// item, it needs to replace what is queued up.
		this._transitionActive = this._clearAfterTransition || (this._pendingItemID != null);

		// call this before clearing prev/next view variables so that subclass
		// overrides have one last chance to access them
		this.transitionComplete();

		// we need to save these in local variables because a new
		// transition may be started in the listeners for the transition
		// complete events, and that will overwrite them.
		var nextView = this._nextViewInTransition;
		var nextItemID = this._nextViewInTransitionID;
		var previousView = this._previousViewInTransition;
		var previousItemID:String = this._previousViewInTransitionID;
		this._previousViewInTransition = null;
		this._previousViewInTransitionID = null;
		this._nextViewInTransition = null;
		this._nextViewInTransitionID = null;

		if (previousView != null) {
			previousView.removeEventListener(Event.RESIZE, activeItemView_resizeHandler);
			this._viewsContainer.removeChild(previousView);
			this.disposeView(previousItemID, previousView);
		}

		// similar to above, make sure that these are populated before the
		// events are dispatched
		this._activeItemView = nextView;
		this._activeItemID = nextItemID;
		this._activeViewMeasurements.save(nextView);
		TransitionEvent.dispatch(this, TransitionEvent.TRANSITION_COMPLETE, previousItemID, previousView, nextItemID, nextView);
		FeathersEvent.dispatch(this, Event.CHANGE);

		this.setInvalid(LAYOUT);

		if (this.stage != null && (this.stage.focus == null || this.stage.focus.stage == null)) {
			if ((nextView is InteractiveObject)) {
				this.stage.focus = cast(nextView, InteractiveObject);
			}
		}

		this._transitionActive = false;
		var pendingTransition = this._pendingItemTransition;
		this._pendingItemTransition = null;
		if (this._clearAfterTransition) {
			this._clearAfterTransition = false;
			this.clearActiveItemInternal(pendingTransition);
		} else if (this._pendingItemID != null) {
			var pendingItemID = this._pendingItemID;
			this._pendingItemID = null;
			this.showItemInternal(pendingItemID, pendingTransition);
		}
	}

	private function transition_cancelHandler(event:Event):Void {
		// consider the transition still active if something is already
		// queued up to happen next. if an event listener asks to show a new
		// item, it needs to replace what is queued up.
		this._transitionActive = this._clearAfterTransition || (this._pendingItemID != null);

		// we need to save these in local variables because a new
		// transition may be started in the listeners for the transition
		// complete events, and that will overwrite them.
		var nextView = this._nextViewInTransition;
		var nextItemID = this._nextViewInTransitionID;
		var previousView = this._previousViewInTransition;
		var previousItemID:String = this._previousViewInTransitionID;
		this._previousViewInTransition = null;
		this._previousViewInTransitionID = null;
		this._nextViewInTransition = null;
		this._nextViewInTransitionID = null;

		if (nextView != null) {
			this._viewsContainer.removeChild(nextView);
			this._activeViewMeasurements.restore(nextView);
			this.disposeView(nextItemID, nextView);
		}

		this._activeItemView = previousView;
		this._activeItemID = previousItemID;
		this._activeViewMeasurements.save(previousView);
		this.transitionCancel();
		TransitionEvent.dispatch(this, TransitionEvent.TRANSITION_CANCEL, previousItemID, previousView, nextItemID, nextView);
		FeathersEvent.dispatch(this, Event.CHANGE);

		this.setInvalid(LAYOUT);

		if (this.stage != null && (this.stage.focus == null || this.stage.focus.stage == null)) {
			if ((this._activeItemView is InteractiveObject)) {
				this.stage.focus = cast(this._activeItemView, InteractiveObject);
			}
		}

		this._transitionActive = false;
		var pendingTransition = this._pendingItemTransition;
		this._pendingItemTransition = null;
		if (this._clearAfterTransition) {
			this._clearAfterTransition = false;
			this.clearActiveItemInternal(pendingTransition);
		} else if (this._pendingItemID != null) {
			var pendingItemID = this._pendingItemID;
			this._pendingItemID = null;
			this.showItemInternal(pendingItemID, pendingTransition);
		}
	}
}

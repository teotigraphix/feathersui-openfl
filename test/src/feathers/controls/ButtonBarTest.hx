/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.data.ArrayCollection;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class ButtonBarTest extends Test {
	private var _buttonBar:ButtonBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._buttonBar = new ButtonBar();
		Lib.current.addChild(this._buttonBar);
	}

	public function teardown():Void {
		if (this._buttonBar.parent != null) {
			this._buttonBar.parent.removeChild(this._buttonBar);
		}
		this._buttonBar = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._buttonBar.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.validateNow();
		this._buttonBar.dataProvider = null;
		this._buttonBar.validateNow();
		Assert.pass();
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var itemIndex = 1;
		var item = this._buttonBar.dataProvider.get(itemIndex);
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._buttonBar.validateNow();
		var sampleItemRenderer = cast(this._buttonBar.itemToButton(item), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);

		this._buttonBar.dataProvider.updateAt(itemIndex);

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(itemIndex, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(itemIndex, setLayoutIndexValues[2]);
	}

	public function testAddItemToDataProviderCreatesNewButton():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._buttonBar.dataProvider = new ArrayCollection([item1]);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.isNull(this._buttonBar.itemToButton(item2));
		this._buttonBar.dataProvider.add(item2);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.notNull(this._buttonBar.itemToButton(item2));
	}

	public function testRemoveItemFromDataProviderDestroysButton():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._buttonBar.dataProvider = new ArrayCollection([item1, item2]);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.notNull(this._buttonBar.itemToButton(item2));
		this._buttonBar.dataProvider.remove(item2);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.isNull(this._buttonBar.itemToButton(item2));
	}
}

private class CustomRendererWithInterfaces extends Button implements IDataRenderer implements ILayoutIndexObject {
	public function new() {
		super();
		this.width = 1.0;
		this.height = 1.0;
	}

	public var setDataValues:Array<Dynamic> = [];

	private var _data:Dynamic;

	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (_data == value) {
			return _data;
		}
		_data = value;
		setDataValues.push(value);
		return _data;
	}

	public var setLayoutIndexValues:Array<Int> = [];

	private var _layoutIndex:Int = -1;

	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return _layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (_layoutIndex == value) {
			return _layoutIndex;
		}
		_layoutIndex = value;
		setLayoutIndexValues.push(value);
		return _layoutIndex;
	}
}

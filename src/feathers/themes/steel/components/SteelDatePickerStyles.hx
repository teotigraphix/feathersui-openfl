/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.DatePicker;
import feathers.controls.Label;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `DatePicker` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelDatePickerStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(DatePicker, null) == null) {
			styleProvider.setStyleFunction(DatePicker, null, function(datePicker:DatePicker):Void {
				if (datePicker.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					datePicker.backgroundSkin = backgroundSkin;
				}

				datePicker.headerGap = 2.0;
			});
		}
		if (styleProvider.getStyleFunction(Label, DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW) == null) {
			styleProvider.setStyleFunction(Label, DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW, function(view:Label):Void {
				if (view.textFormat == null) {
					view.textFormat = theme.getTextFormat();
				}
				if (view.disabledTextFormat == null) {
					view.disabledTextFormat = theme.getDisabledTextFormat();
				}
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(0xff00ff, 0.0);
					icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					icon.graphics.endFill();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(2.0, 4.0);
					icon.graphics.lineTo(6.0, 0.0);
					icon.graphics.lineTo(6.0, 8.0);
					icon.graphics.lineTo(2.0, 4.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(0xff00ff, 0.0);
					disabledIcon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					disabledIcon.graphics.endFill();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(2.0, 4.0);
					disabledIcon.graphics.lineTo(6.0, 0.0);
					disabledIcon.graphics.lineTo(6.0, 8.0);
					disabledIcon.graphics.lineTo(2.0, 4.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(0xff00ff, 0.0);
					icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					icon.graphics.endFill();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(2.0, 0.0);
					icon.graphics.lineTo(6.0, 4.0);
					icon.graphics.lineTo(2.0, 8.0);
					icon.graphics.lineTo(2.0, 0.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(0xff00ff, 0.0);
					disabledIcon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					disabledIcon.graphics.endFill();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(2.0, 0.0);
					disabledIcon.graphics.lineTo(6.0, 4.0);
					disabledIcon.graphics.lineTo(2.0, 8.0);
					disabledIcon.graphics.lineTo(2.0, 0.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(0.0, 4.0);
					icon.graphics.lineTo(4.0, 0.0);
					icon.graphics.lineTo(4.0, 8.0);
					icon.graphics.lineTo(0.0, 4.0);
					icon.graphics.moveTo(4.0, 4.0);
					icon.graphics.lineTo(8.0, 0.0);
					icon.graphics.lineTo(8.0, 8.0);
					icon.graphics.lineTo(4.0, 4.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(0.0, 4.0);
					disabledIcon.graphics.lineTo(4.0, 0.0);
					disabledIcon.graphics.lineTo(4.0, 8.0);
					disabledIcon.graphics.lineTo(0.0, 4.0);
					disabledIcon.graphics.moveTo(4.0, 4.0);
					disabledIcon.graphics.lineTo(8.0, 0.0);
					disabledIcon.graphics.lineTo(8.0, 8.0);
					disabledIcon.graphics.lineTo(4.0, 4.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(0.0, 0.0);
					icon.graphics.lineTo(4.0, 4.0);
					icon.graphics.lineTo(0.0, 8.0);
					icon.graphics.lineTo(0.0, 0.0);
					icon.graphics.moveTo(4.0, 0.0);
					icon.graphics.lineTo(8.0, 4.0);
					icon.graphics.lineTo(4.0, 8.0);
					icon.graphics.lineTo(4.0, 0.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(0.0, 0.0);
					disabledIcon.graphics.lineTo(4.0, 4.0);
					disabledIcon.graphics.lineTo(0.0, 8.0);
					disabledIcon.graphics.lineTo(0.0, 0.0);
					disabledIcon.graphics.moveTo(4.0, 0.0);
					disabledIcon.graphics.lineTo(8.0, 4.0);
					disabledIcon.graphics.lineTo(4.0, 8.0);
					disabledIcon.graphics.lineTo(4.0, 0.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Label, DatePicker.CHILD_VARIANT_WEEKDAY_LABEL) == null) {
			styleProvider.setStyleFunction(Label, DatePicker.CHILD_VARIANT_WEEKDAY_LABEL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getSecondaryTextFormat(CENTER);
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat(CENTER);
				}
				label.verticalAlign = MIDDLE;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_DATE_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_DATE_RENDERER, function(dateRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (dateRenderer.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0xff00ff, 0.0);
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					backgroundSkin.selectedBorder = theme.getSelectedBorder();
					backgroundSkin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					backgroundSkin.cornerRadius = 4.0;
					dateRenderer.backgroundSkin = backgroundSkin;
				}

				if (dateRenderer.textFormat == null) {
					dateRenderer.textFormat = theme.getTextFormat();
				}
				if (dateRenderer.disabledTextFormat == null) {
					dateRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (dateRenderer.secondaryTextFormat == null) {
					dateRenderer.secondaryTextFormat = theme.getDetailTextFormat();
				}
				if (dateRenderer.disabledSecondaryTextFormat == null) {
					dateRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				dateRenderer.horizontalAlign = CENTER;
				dateRenderer.verticalAlign = MIDDLE;

				dateRenderer.paddingTop = 2.0;
				dateRenderer.paddingRight = 2.0;
				dateRenderer.paddingBottom = 2.0;
				dateRenderer.paddingLeft = 2.0;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER, function(dateRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (dateRenderer.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0xff00ff, 0.0);
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					backgroundSkin.selectedBorder = theme.getSelectedBorder();
					backgroundSkin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					backgroundSkin.cornerRadius = 4.0;
					dateRenderer.backgroundSkin = backgroundSkin;
				}

				if (dateRenderer.textFormat == null) {
					dateRenderer.textFormat = theme.getSecondaryTextFormat();
				}
				if (dateRenderer.disabledTextFormat == null) {
					dateRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (dateRenderer.secondaryTextFormat == null) {
					dateRenderer.secondaryTextFormat = theme.getDetailTextFormat();
				}
				if (dateRenderer.disabledSecondaryTextFormat == null) {
					dateRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				dateRenderer.horizontalAlign = CENTER;
				dateRenderer.verticalAlign = MIDDLE;

				dateRenderer.paddingTop = 2.0;
				dateRenderer.paddingRight = 2.0;
				dateRenderer.paddingBottom = 2.0;
				dateRenderer.paddingLeft = 2.0;
			});
		}
	}
}

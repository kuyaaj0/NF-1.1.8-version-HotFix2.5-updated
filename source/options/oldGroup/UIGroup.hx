package options.group;

class UIGroup
{
	static public function add(follow:OptionBG)
	{
		var option:Option = new Option(Language.get('GameUI'), TITLE);
		follow.addOption(option);

		var reset:ResetRect = new ResetRect(450, 20, follow);
		follow.add(reset);

		///////////////////////////////

		var option:Option = new Option(Language.get('Visble'), TEXT);
		follow.addOption(option);

		var option:Option = new Option(Language.get('hideHud'), 'hideHud', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('showComboNum'), 'showComboNum', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('showRating'), 'showRating', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('opponentStrums'), 'opponentStrums', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('judgementCounter'), 'judgementCounter', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('KeyboardViewer'), 'KeyboardViewer', BOOL);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('TimeBar'), TEXT);
		follow.addOption(option);

		var TimeBarArray:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
		var option:Option = new Option(Language.get('timeBarType'), 'timeBarType', STRING, TimeBarArray);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('HealthBar'), TEXT);
		follow.addOption(option);

		var option:Option = new Option(Language.get('healthBarAlpha'), 'healthBarAlpha', FLOAT, 0, 1, 1);
		follow.addOption(option);

		var option:Option = new Option(Language.get('oldHealthBarVersion'), 'oldHealthBarVersion', BOOL);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('Combo'), TEXT);
		follow.addOption(option);

		var option:Option = new Option(Language.get('comboColor'), 'comboColor', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('comboOffsetFix'), 'comboOffsetFix', BOOL);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('KeyBoard'), TEXT);
		follow.addOption(option);

		var option:Option = new Option(Language.get('keyboardAlpha'), 'keyboardAlpha', FLOAT, 0, 1, 1);
		follow.addOption(option);

		var option:Option = new Option(Language.get('keyboardTimeDisplay'), 'keyboardTimeDisplay', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('keyboardTime'), 'keyboardTime', INT, 0, 1000, 0, 'MS');
		follow.addOption(option);

		var colorStingArray = [
			'BLACK', 'WHITE', 'GRAY', 'RED', 'GREEN', 'BLUE', 'YELLOW', 'PINK', 'ORANGE', 'PURPLE', 'BROWN', 'CYAN'
		];

		var option:Option = new Option(Language.get('keyboardBGColor'), 'keyboardBGColor', STRING, colorStingArray);
		follow.addOption(option);

		var option:Option = new Option(Language.get('keyboardTextColor'), 'keyboardTextColor', STRING, colorStingArray);
		follow.addOption(option);

		///////////////////////////////

		var option:Option = new Option(Language.get('Camera'), TEXT);
		follow.addOption(option);

		var option:Option = new Option(Language.get('camZooms'), 'camZooms', BOOL);
		follow.addOption(option);

		var option:Option = new Option(Language.get('scoreZoom'), 'scoreZoom', BOOL);
		follow.addOption(option);
	}
}

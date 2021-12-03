#Persistent
#ppattiemo
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen
Coordmode, Mouse, Screen

;-------------------------------------------------------------------------------------
;	Constants definition
;-------------------------------------------------------------------------------------


DEBUG_MODE := true

; Defines the time that script sleeps between clock ticks in ms
SLEEP_PERIOD_MS := 100

; Defines the period to do an action to keep the game alive
KEEP_GAME_ALIVE_PERIOD_MS := 5 * 60 * 1000

; Defines the period to put the heroes to work
HEROES_WORK_PERIOD_MS := 15 * 60 * 1000

ERROR_DLG_IMAGE_PATH := "error_dlg_title_136x41.bmp"
ERROR_DLG_OK_BTTN_IMAGE_PATH := "error_dlg_ok_bttn_80x51.bmp"
ERROR_DLG_X_BTTN_IMAGE_PATH := "heroes_close_bttn_52x55.bmp"

LOGIN_SCREEN_IMAGE_PATH := "login_screen_666x316.bmp"
MAIN_SCREEN_IMAGE_PATH := "main_screen_345x463.bmp"
TREASURE_HUNT_SCREEN_IMAGE := "treasure_hunt_screen_266x52.bmp"

LOGIN_CONNECT_WALLET_IMAGE_BTTN_PATH := "login_connect_wallet_208x94.bmp"
LOGIN_SELECT_WALLET_IMAGE_BTTN_PATH := "login_select_wallet_142x32.bmp"
LOGIN_SELECT_WALLET_DARK_IMAGE_BTTN_PATH := "login_select_wallet_dark_182x25.bmp"
LOGIN_SIGNING_WALLET_IMAGE_BTTN_PATH := "login_sign_wallet_87x42.bmp"

MAIN_TRASURE_HUNT_IMAGE_BTTN_PATH := "main_treasure_hunt_152x222.bmp"
MAIN_HEROES_IMAGE_BTTN_PATH := "main_heroes_selection_43x104.bmp"

HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH := "heroes_characters_title_bar_783x52.bmp"
HEROES_WORK_IMAGE_BTTN_PATH := "heroes_work_bttn_57x31.bmp"
HEROES_CLOSE_IMAGE_BTTN_PATH := "heroes_close_bttn_52x55.bmp"

TREASURE_HUNT_BACK_IMAGE_BTTN_PATH := "treasure_hunt_back_bttn_64x43.bmp"
TREASURE_HUNT_NEW_MAP_IMAGE_BTTN_PATH := "new_map_bttn_233x50.bmp"

ROBOT_CHECK_PUZZLE_IMAGE_PATH := "robot_check_puzzle_piece.bmp"
ROBOT_CHECK_SLIDER_BAR_START := "robot_slider_bar_start.bmp"
ROBOT_CHECK_SLIDER_BAR_END := "robot_slider_bar_end_11.bmp"
ROBOT_CHECK_PUZZLE_BAR_START := "robot_check_wnd_left_side.bmp"
ROBOT_CHECK_PUZZLE_BAR_END := "robot_check_wnd_right_side.bmp"

ROBOT_WND_CONTENT_LENGTH_PIX := 468


;-------------------------------------------------------------------------------------
;	Data types declaration
;-------------------------------------------------------------------------------------

;	class BombGameCtrlState: defines the state of a Bombcrypto game
class BombGameCtrlState
{
	;--------------------------------------------------------------------------------
	; Construction
	
	__New(x, y, width, height, chromeProfile) {
		if (x >= 0 && y >= 0 && width >= 0 && height >= 0) {
		
			; Game windows rectangle
			this._x := x
			this._y := y
			this._width := width
			this._height := height
			
			; Current state of the game
			this._current_screen := 0	; 0 - login, 1 - main menu, 2 - hero control, 3 - mining
			
			this._loginState := 0 ; 0 - in login screen, 1 - after clicking connect, 2 - signing wallet, 3 - signign delay, 4 - check new screen
			
			this._mainScreenState := 0 ;
			
			this._heroesScreenState := 0 ;
			
			this._treasureHuntScreenState := 0 ;
			
			; Period the control should wait without acting (i.e. should sleep)
			this._sleepingPeriod := 0
			
			this._startSleepingTime := 0
			
			this._lastGameRefreshTime := 0
			
			this._lastHeroBackToWorkTime := 0
			
			this._heroeToWorkAttempt := 0
			
			this._errorStartSleepingTime := 0
			
			this._chromeProfile := chromeProfile
			
			return this
		}
		
		return ""
	}
	
	;--------------------------------------------------------------------------------
	; Properties
	
	CurrentScreen {
		get {
			return this._current_screen
		}
		set {
			if (value > 0 && value < 4 && this._current_screen != value) {
				this.ResetScreensStates()
				this._current_screen := value
			}
		}
	}
	
	WindowRect {
		get {
			return this._windowRec
		}
		set {
		}
	}
	
	LoginState {
		get {
			return this._loginState
		}
		set {
			if (value > -1 && value < 5) {
				this._loginState := value
			}
		}
	}
	
	MainMenuState {
		get {
			return this._mainScreenState
		}
		set {
			if (value > -1 && value < 20) {
				this._mainScreenState := value
			}
		}
	}
	
	HeroesScreenState {
		get {
			return this._heroesScreenState
		}
		set {
			;if (value > -1 && value < 20) {
				this._heroesScreenState := value
			;}
		}
	}
	TreasureHuntScreenState {
		get {
			return this._treasureHuntScreenState
		}
		set {
			;if (value > -1 && value < 20) {
				this._treasureHuntScreenState := value
			;}
		}
	}
	
	SleepingPeriod {
		get {
			return this._sleepingPeriod
		}
		set {
		}
	}
	
	TimeSlept {
		get {
			return this.IsSleeping() ? A_TickCount - this._startSleepingTime : 0
		}
		set {
		}
	}
	
	LastRefreshTime {
		get {
			return this._lastGameRefreshTime
		}
		set {
			this._lastGameRefreshTime := value
		}
	}
	
	LastHeroBackToWorkTime {
		get {
			return this._lastHeroBackToWorkTime
		}
		set {
			this._lastHeroBackToWorkTime := value
		}
	}
	
	HeroeToWorkAttempt {
		get {
			return this._heroeToWorkAttempt
		}
		set {
			this._heroeToWorkAttempt := value
		}
	}
	
	ErrorStartSleepingTime {
		get {
			return this._errorStartSleepingTime
		}
		set {
			this._errorStartSleepingTime := value
		}
	}
	
	WinX {
		get {
			return this._x
		}
		set {
		}
	}
	
	WinY {
		get {
			return this._y
		}
		set {
		}
	}
	
	WinWidth {
		get {
			return this._width
		}
		set {
		}
	}
	
	WinHeight {
		get {
			return this._height
		}
		set {
		}
	}
	
	;--------------------------------------------------------------------------------
	; Methods
	
	ResetScreensStates() {
		this.WakeUp()
		this.LoginState := 0
		this.MainMenuState := 0
		this.HeroesScreenState := 0
		this.TreasureHuntScreenState := 0
	}
	
	GoToSleep(durationMs) {
		this._sleepingPeriod := durationMs
		this._startSleepingTime := A_TickCount
	}
	
	WakeUp() {
		this._sleepingPeriod := 0
		this._startSleepingTime := 0
	}
	
	IsSleeping() {
		return this._sleepingPeriod > 0
	}
	
	ActivateWindow() {
		chromeProfile := this._chromeProfile
		sPat = chrome.exe.*--profile-directory="%chromeProfile%"
		for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process  where Name = 'chrome.exe'") {
			if RegExMatch(process.Commandline, sPat){
				processId :=process.ProcessId
				WinActivate, ahk_pid %processId%
				WinWaitActive, ahk_pid %processId%
			}
		}
	}
}


;-------------------------------------------------------------------------------------
;	Function definitions
;-------------------------------------------------------------------------------------

TimeMsToClockTicks(timeMs)
{
	global SLEEP_PERIOD_MS
	return Ceil(timeMs / SLEEP_PERIOD_MS)
}

;	function CanFindImage: returns ture if it can find the image in the given window rect
CanFindImage(imagePath, winX, winY, winWidth, winHeight)
{
	ImageSearch, foundX, foundY, winX, winY, winX + winWidth, winY + winHeight, *10 %imagePath%
	if(foundX != "") {
		return true
	}
	
	return false
}

FindImage(imagePath, winX, winY, winWidth, winHeight, tolerance, ByRef xPos, ByRef yPos)
{
	xPos := ""
	yPos := ""
	ImageSearch, xPos, yPos, winX, winY, winX + winWidth, winY + winHeight, *%tolerance% %imagePath%
	if(xPos != "") {
		return true
	}
	
	return false
}

;	function ClickImage: clicks on the image found in the given window rect
ClickImage(imagePath, winX, winY, winWidth, winHeight, ignoreDebug, tolerance)
{
	ImageSearch, foundX, foundY, winX, winY, winX + winWidth, winY + winHeight, *%tolerance% %imagePath%
	if(foundX != "") {
		Click, %foundX% %foundY%
		return true
	}
	
	global DEBUG_MODE
	if (DEBUG_MODE == true && ignoreDebug == false) {
		MsgBox % "Image <" . imagePath . "> could not be found"
	}
	
	return false
}

FindCurrentScreen(winX, winY, winWidth, winHeight)
{
	global LOGIN_SCREEN_IMAGE_PATH
	imageFound := CanFindImage(LOGIN_SCREEN_IMAGE_PATH, winX, winY, winWidth, winHeight)
	if (imageFound == true) {
		return 0
	}

	global MAIN_SCREEN_IMAGE_PATH
	imageFound := CanFindImage(MAIN_SCREEN_IMAGE_PATH, winX, winY, winWidth, winHeight)
	if (imageFound == true) {
		return 1
	}
	
	global HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH
	imageFound := CanFindImage(HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH, winX, winY, winWidth, winHeight)
	if (imageFound == true) {
		return 2
	}
	
	global TREASURE_HUNT_SCREEN_IMAGE
	imageFound := CanFindImage(TREASURE_HUNT_SCREEN_IMAGE, winX, winY, winWidth, winHeight)
	if (imageFound == true) {
		return 3
	}
		
	return -1
}

HandleRobotCheck(winX, winY, winWidth, winHeight)
{
	xRobotBarSliderPos := 0
	yRobotBarSliderPos := 0

	global ROBOT_CHECK_SLIDER_BAR_START
	foundRobotCheck := FindImage(ROBOT_CHECK_SLIDER_BAR_START, winX, winY, winWidth, winHeight, 10, xRobotBarSliderPos, yRobotBarSliderPos)
	if (foundRobotCheck == false) {
		return
	}	
	
	;Click, %xRobotBarSliderPos% %yRobotBarSliderPos%
	;MsgBox "Wait"
	
	xSliderBarEnd := 0
	ySliderBarEnd := 0
	
	global ROBOT_CHECK_SLIDER_BAR_END
	foundEnd := FindImage(ROBOT_CHECK_SLIDER_BAR_END, winX, winY, winWidth, winHeight, 10, xSliderBarEnd, ySliderBarEnd)
	if (foundEnd == false) {
		global DEBUG_MODE
		if (DEBUG_MODE == true) {
			MsgBox "Error finding the end of the robot check slider bar"
		}
		return
	}
	
	sliderBarLength := xSliderBarEnd + (11 - 9) - (xRobotBarSliderPos + 33)
	
	xPuzzleBarStart := 0
	yPuzzleBarStart := 0
	global ROBOT_CHECK_PUZZLE_BAR_START
	foundEnd := FindImage(ROBOT_CHECK_PUZZLE_BAR_START, winX, winY, winWidth, winHeight, 5, xPuzzleBarStart, yPuzzleBarStart)
	if (foundEnd == false) {
		global DEBUG_MODE
		if (DEBUG_MODE == true) {
			MsgBox "Error finding the end of the robot check window start"
		}
		return
	}
	
	xPuzzleBarEnd := 0
	yPuzzleBarEnd := 0
	global ROBOT_CHECK_PUZZLE_BAR_END
	foundEnd := FindImage(ROBOT_CHECK_PUZZLE_BAR_END, winX, winY, winWidth, winHeight, 5, xPuzzleBarEnd, yPuzzleBarEnd)
	if (foundEnd == false) {
		global DEBUG_MODE
		if (DEBUG_MODE == true) {
			MsgBox "Error finding the end of the robot check window end"
		}
		return
	}
	
	puzzleBarLength := xPuzzleBarEnd + 82 - 168 - (xPuzzleBarStart + 96)
	
	xRobotBarSliderPos += 33
	yRobotBarSliderPos += 36
	
	robotPuzzleX := xRobotBarSliderPos
	global ROBOT_WND_CONTENT_LENGTH_PIX
	robotPuzzleY := yRobotBarSliderPos - ROBOT_WND_CONTENT_LENGTH_PIX
	
	foundRobotCheck:= false
	Loop
	{
		xPos := 0
		yPos := 0
		global ROBOT_CHECK_PUZZLE_IMAGE_PATH
		foundRobotCheck := FindImage(ROBOT_CHECK_PUZZLE_IMAGE_PATH, robotPuzzleX - 100, robotPuzzleY, ROBOT_WND_CONTENT_LENGTH_PIX, ROBOT_WND_CONTENT_LENGTH_PIX, 85, xPos, yPos)
		if (foundRobotCheck == true) {
			;Click, %xPos% %yPos%
			;MsgBox "Found the missing puzzle"
			xPos := xPos - (xPuzzleBarStart + 96)
			xEndPos := xPos * sliderBarLength / puzzleBarLength + xRobotBarSliderPos
			
			MouseMove, xRobotBarSliderPos, yRobotBarSliderPos, 0
			
			SendMode Event
			MouseClickDrag, Left, xRobotBarSliderPos, yRobotBarSliderPos, xEndPos, yRobotBarSliderPos, 90
			SendMode Input
			
			break
		}
	}
	
	Sleep, 2000
}


;	function ControlGame: controls the state of a Bombcrypto game by acting on it
;	gameState: in/out parameter of type BombGameCtrlState
ControlGame(ByRef gameState)
{
	HandleRobotCheck(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
	
	if (gameState.ErrorStartSleepingTime != 0) {
		if (A_TickCount - gameState.ErrorStartSleepingTime < 60000) {
			return
		} else {
			gameState.ErrorStartSleepingTime := 0
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				global DEBUG_MODE
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; please restart the script"
				}
			} else if (gameState.CurrentScreen != currentScreen) {
				gameState.CurrentScreen := currentScreen
				return
			}
		}
	}

	global ERROR_DLG_IMAGE_PATH
	imageFound := CanFindImage(ERROR_DLG_IMAGE_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
	if (imageFound == true) {
		gameState.ActivateWindow()
		global ERROR_DLG_OK_BTTN_IMAGE_PATH
		okBttnClicked := ClickImage(ERROR_DLG_OK_BTTN_IMAGE_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 10)
		if (okBttnClicked == true) {
			gameState.ErrorStartSleepingTime := A_TickCount
			return
		} else {
			global ERROR_DLG_X_BTTN_IMAGE_PATH
			closeBttnClicked := ClickImage(ERROR_DLG_X_BTTN_IMAGE_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 10)
			if (closeBttnClicked == true) {
				gameState.ErrorStartSleepingTime := A_TickCount
				return
			}
		}
	}

	if (gameState.IsSleeping()) {
		if (gameState.TimeSlept > gameState.SleepingPeriod) {
			gameState.WakeUp()
		} else {
			return	; Still waiting for something
		}
	}
			
	if (gameState.CurrentScreen == 0) {
		if (gameState.LoginState == 0) {
			gameState.ActivateWindow()
			global LOGIN_CONNECT_WALLET_IMAGE_BTTN_PATH
			walletClicked := ClickImage(LOGIN_CONNECT_WALLET_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
			if (walletClicked == true) {
				gameState.GoToSleep(2000)
				gameState.LoginState := 1
			}
		} else if (gameState.LoginState == 1) {
			global LOGIN_SELECT_WALLET_IMAGE_BTTN_PATH
			selectWalletClicked := ClickImage(LOGIN_SELECT_WALLET_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 10)
			if (selectWalletClicked == true) {
				gameState.GoToSleep(10000)
				gameState.LoginState := 2
			} else {
				global LOGIN_SELECT_WALLET_DARK_IMAGE_BTTN_PATH
				selectDarkWalletClicked := ClickImage(LOGIN_SELECT_WALLET_DARK_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 10)
				global DEBUG_MODE
				if (selectDarkWalletClicked == true) {
					gameState.GoToSleep(10000)
					gameState.LoginState := 2
				} else if (DEBUG_MODE == true) {
					MsgBox % "Image <" . LOGIN_SELECT_WALLET_IMAGE_BTTN_PATH . "> and <" . LOGIN_SELECT_WALLET_DARK_IMAGE_BTTN_PATH . "> could not be found"
				}
			}
		} else if (gameState.LoginState == 2) {
			global LOGIN_SIGNING_WALLET_IMAGE_BTTN_PATH
			ImageSearch, foundX, foundY, gameState.WinX, gameState.WinY, gameState.WinX + gameState.WinWidth, gameState.WinY + gameState.WinHeight, *10 %LOGIN_SIGNING_WALLET_IMAGE_BTTN_PATH%
			global DEBUG_MODE
			if(foundX != "") {
				Click, %foundX% %foundY% Down
				Sleep, 600
				Click, Up
				gameState.GoToSleep(60000)
				gameState.LoginState := 3
			} else if (DEBUG_MODE == true) {
				MsgBox % "Image <" . LOGIN_SIGNING_WALLET_IMAGE_BTTN_PATH . "> could not be found"
			}
		} else if (gameState.LoginState == 3) {
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; main screen was expected"
				}
			} else {
				gameState.LoginState := 0
				gameState.CurrentScreen := currentScreen
			}
		
			;Click, Up
			;gameState.GoToSleep(60000)
			;gameState.LoginState := 4
		}
		;else if (gameState.LoginState == 4) {
		;	currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
		;	if (currentScreen == -1) {
		;		if (DEBUG_MODE == true) {
		;			MsgBox "There has been an error; main screen was expected"
		;		}
		;	} else {
		;		gameState.LoginState := 0
		;		gameState.CurrentScreen := currentScreen
		;	}
		;}
	} else if (gameState.CurrentScreen == 1) {
		if (gameState.MainMenuState == 0) {
			gameState.ActivateWindow()
			global MAIN_HEROES_IMAGE_BTTN_PATH
			heroesClicked := ClickImage(MAIN_HEROES_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
			if (heroesClicked == true) {
				gameState.GoToSleep(30000)
				gameState.MainMenuState := 2
				gameState.LastRefreshTime := A_TickCount
			}
		} else if (gameState.MainMenuState == 1) {
			gameState.ActivateWindow()
			global MAIN_TRASURE_HUNT_IMAGE_BTTN_PATH
			treasureHuntClicked := ClickImage(MAIN_TRASURE_HUNT_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
			if (treasureHuntClicked == true) {
				gameState.GoToSleep(3000)
				gameState.MainMenuState := 2
				gameState.LastRefreshTime := A_TickCount
			}
		} else if (gameState.MainMenuState == 2) {
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; heroes o treasure hunt screen was expected"
				}
			} else {
				gameState.MainMenuState := 0
				gameState.CurrentScreen := currentScreen
			}
		}
	} else if (gameState.CurrentScreen == 2) {
		if (gameState.HeroesScreenState == 0) {
			gameState.ActivateWindow()
			global HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH
			ImageSearch, foundX, foundY, gameState.WinX, gameState.WinY, gameState.WinX + gameState.WinWidth, gameState.WinY + gameState.WinHeight, *10 %HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH%
			global DEBUG_MODE
			if(foundX != "") {
				Click, %foundX% %foundY% 
				foundX += 300
				foundY += 300
				Loop, 40
				{
					Click, %foundX% %foundY% WheelDown
					Sleep, 100
				}
				
				Sleep, 2000
				
				Loop, 20
				{
					global HEROES_WORK_IMAGE_BTTN_PATH
					ClickImage(HEROES_WORK_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 3)
					Sleep, 2000
				}
				
				gameState.HeroesScreenState := 1
				gameState.GoToSleep(2000)
			} else if (DEBUG_MODE == true) {
				MsgBox % "Image <" . HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH . "> could not be found"
			}
		} else if (gameState.HeroesScreenState == 1) {
			gameState.ActivateWindow()
			;global HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH
			;ImageSearch, foundX, foundY, gameState.WinX, gameState.WinY, gameState.WinX + gameState.WinWidth, gameState.WinY + gameState.WinHeight, *10 %HEROES_CHARACTERS_TITLE_BAR_IMAGE_PATH%
			;if(foundX != "") {
			;	Click, %foundX% %foundY%
			;}
			;global HEROES_WORK_IMAGE_BTTN_PATH
			;heroeWorkClicked := ClickImage(HEROES_WORK_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 50)
			;if (heroeWorkClicked == true) {
			;	gameState.GoToSleep(2000)
			;} else {
			;	gameState.HeroeToWorkAttempt := gameState.HeroeToWorkAttempt + 1
			;	if (gameState.HeroeToWorkAttempt > 10) {
					global HEROES_CLOSE_IMAGE_BTTN_PATH
					heroesCloseClicked := ClickImage(HEROES_CLOSE_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
					if (heroesCloseClicked == true) {
						gameState.GoToSleep(5000)
						gameState.HeroesScreenState := 2
			;			gameState.HeroeToWorkAttempt := 0
					}
			;	} else {
			;		gameState.GoToSleep(1000)
			;	}
			;}
		} else if (gameState.HeroesScreenState == 2) {
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; main screen was expected"
				}
			} else {
				gameState.LastRefreshTime := A_TickCount
				gameState.LastHeroBackToWorkTime := A_TickCount
				gameState.HeroesScreenState := 0
				gameState.CurrentScreen := currentScreen
				if (currentScreen == 1) {
					gameState.MainMenuState := 1
				}
			}
		}
	} else if (gameState.CurrentScreen == 3) {
		if (gameState.TreasureHuntScreenState == 0) {
			global TREASURE_HUNT_NEW_MAP_IMAGE_BTTN_PATH
			newMapClicked := ClickImage(TREASURE_HUNT_NEW_MAP_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, true, 10)
			if (newMapClicked != true) {
				global HEROES_WORK_PERIOD_MS
				global KEEP_GAME_ALIVE_PERIOD_MS
				if (A_TickCount - gameState.LastHeroBackToWorkTime > HEROES_WORK_PERIOD_MS) {
					global TREASURE_HUNT_BACK_IMAGE_BTTN_PATH
					backBttnClicked := ClickImage(TREASURE_HUNT_BACK_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
					if (backBttnClicked == true) {
						gameState.GoToSleep(2000)
						gameState.TreasureHuntScreenState := 1
					}
				}
				else if (A_TickCount - gameState.LastRefreshTime > KEEP_GAME_ALIVE_PERIOD_MS) {
					global TREASURE_HUNT_BACK_IMAGE_BTTN_PATH
					backBttnClicked := ClickImage(TREASURE_HUNT_BACK_IMAGE_BTTN_PATH, gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight, false, 10)
					if (backBttnClicked == true) {
						gameState.GoToSleep(2000)
						gameState.TreasureHuntScreenState := 2
					}
				}
			} else {
				gameState.LastRefreshTime := A_TickCount
			}			
		} else if (gameState.TreasureHuntScreenState == 1) {
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; main screen was expected o go to heroes"
				}
			} else {
				gameState.TreasureHuntScreenState := 0
				gameState.CurrentScreen := currentScreen
				if (currentScreen == 1) {
					gameState.MainMenuState := 0
				}
			}
		}
		else if (gameState.TreasureHuntScreenState == 2) {
			currentScreen := FindCurrentScreen(gameState.WinX, gameState.WinY, gameState.WinWidth, gameState.WinHeight)
			if (currentScreen == -1) {
				if (DEBUG_MODE == true) {
					MsgBox "There has been an error; main screen was expected to refresh game"
				}
			} else {
				gameState.TreasureHuntScreenState := 0
				gameState.CurrentScreen := currentScreen
				if (currentScreen == 1) {
					gameState.MainMenuState := 1
				}
			}
		}
	}
}


;-------------------------------------------------------------------------------------
;	Global variables
;-------------------------------------------------------------------------------------

game1State := new BombGameCtrlState(0, 0, 1920, A_ScreenHeight, "Profile 1")
game1State.CurrentScreen := 1

game2State := new BombGameCtrlState(1920, 0, 1920, A_ScreenHeight, "Profile 2")
game2State.CurrentScreen := 1


;-------------------------------------------------------------------------------------
;	Main loop
;-------------------------------------------------------------------------------------

Loop,
{
	global SLEEP_PERIOD_MS
	Sleep, SLEEP_PERIOD_MS
	
	global game1State
	ControlGame(game1State)
	
	global game2State
	ControlGame(game2State)
}

ExitApp

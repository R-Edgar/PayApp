-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--
--  External modules
--
local unitTest  = require(  "unitTest"  )
local widget    = require(  "widget"    )
local socket    = require(  "socket"    )
local crypto    = require(  "crypto"    )

--
--  UI defines
--
local fontSize          = 80
local overlayAlpha      = 0.5
local alphaGrade1       = 0.5
local alphaGrade2       = 0.75
local posYTopBar        = display.contentHeight / 16
local posYStatusField   = display.contentHeight * 3 / 16
local posYProgressBar   = display.contentHeight * 1 / 4
local posYAmountField   = display.contentHeight * 5 / 16
local posYCardNumField  = display.contentHeight * 7 / 16
local status            = "Please enter your card details"
local lockUserEntry     = false
local enableUnitTests   = false -- Flag to enable unit testing.

--
--  Data defines
--
local cardNumberdigitsCount = 1
local cardNumber            = { "_", "_", "_", "_", "_", "_", "_", "_" } -- Elements of card data table initialised to "_" in order to allow checking if fully entered, and for displaying on UI.
local progress              = 0

--
--  Arrange elements on screen
--
local background = display.newImage("background.jpg", display.screenOriginX, display.screenOriginY)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Top bar to display the app logo.
local topBar = display.newRect(display.contentCenterX, posYTopBar, display.contentWidth, display.contentHeight / 8)
topBar:setFillColor(  23/255, 66/255, 199/255, 0.5 )

local topBarText = display.newText("PayApp", display.contentCenterX, posYTopBar + posYTopBar / 3, native.systemFontBold, fontSize * 2)

-- Text to display the status of the transaction and any instructions to user/merchant.
local statusText = display.newText( status, display.contentCenterX, posYStatusField, native.systemFontBold, fontSize )
statusText:setFillColor( 23/255, 66/255, 199/255 )

  -- Create progress bar widget
  local progressView = widget.newProgressView(
    {
        fillHeight = 64,
        left = display.contentWidth * 0.125,
        top = posYProgressBar,
        height = 600,
        width = display.contentWidth * 0.75,
        isAnimated = true
    }
  )

  progressView.isVisible = false

-- Text to display the amount set by the merchant.
local amountText = display.newText( "Amount: £12.00", display.contentCenterX, posYAmountField, native.systemFontBold, fontSize )
amountText:setFillColor( 23/255, 66/255, 199/255 )

--
-- Draw circles in which to display each card digit, separated by a "-" in the middle.
--
local cardNumFieldRadius = display.contentWidth / 20
local cardNumFieldSpacing = display.contentWidth / 18


local cardNumBkgdCircle1 = display.newCircle(cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle2 = display.newCircle(3 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle3 = display.newCircle(5 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle4 = display.newCircle(7 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle5 = display.newCircle(11 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle6 = display.newCircle(13 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle7 = display.newCircle(15 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)
local cardNumBkgdCircle8 = display.newCircle(17 * cardNumFieldSpacing, posYCardNumField, cardNumFieldRadius)

local cardNumDig1Text = display.newText(cardNumber[1],        cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig2Text = display.newText(cardNumber[2],  3   * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig3Text = display.newText(cardNumber[3],  5   * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig4Text = display.newText(cardNumber[4],  7   * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumSpcrText = display.newText("-",            9   * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig5Text = display.newText(cardNumber[5],  11  * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig6Text = display.newText(cardNumber[6],  13  * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig7Text = display.newText(cardNumber[7],  15  * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)
local cardNumDig8Text = display.newText(cardNumber[8],  17  * cardNumFieldSpacing, posYCardNumField, native.systemFontBold, fontSize)

cardNumBkgdCircle1:setFillColor( 1, 1, 1, 0.4 )
cardNumBkgdCircle2:setFillColor( 1, 1, 1, 0.3 )
cardNumBkgdCircle3:setFillColor( 1, 1, 1, 0.2 )
cardNumBkgdCircle4:setFillColor( 1, 1, 1, 0.1 )
cardNumBkgdCircle5:setFillColor( 1, 1, 1, 0.1 )
cardNumBkgdCircle6:setFillColor( 1, 1, 1, 0.2 )
cardNumBkgdCircle7:setFillColor( 1, 1, 1, 0.3 )
cardNumBkgdCircle8:setFillColor( 1, 1, 1, 0.4 )

cardNumDig1Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig2Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig3Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig4Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumSpcrText:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig5Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig6Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig7Text:setFillColor( 23/255, 66/255, 199/255 )
cardNumDig8Text:setFillColor( 23/255, 66/255, 199/255 )

--
-- Draw a number pad at the bottom of the screen with cancel, clear, and enter buttons.
--
local numPadGroup = display.newGroup()

numPadGroup.x = display.screenOriginX
numPadGroup.y = display.contentHeight * 0.5

--  Draw a rectangle with dimensions of half screen size, centred on the middle of the lower half of the screen.
local numPadBkgd  = display.newRect(display.contentWidth / 2, display.contentHeight / 4, display.contentWidth, display.contentHeight/2)
numPadBkgd:setFillColor(1, 1, 1, overlayAlpha)

numPadGroup:insert( numPadBkgd )

local buttonW = display.contentWidth / 3
local buttonH = display.contentHeight / 10

local posXCol1  = buttonW / 2
local posXCol2  = buttonW + buttonW / 2
local posXCol3  = buttonW * 2 + buttonW / 2

local posYRow1  = buttonH / 2
local posYRow2  = buttonH / 2 + buttonH
local posYRow3  = buttonH / 2 + buttonH * 2
local posYRow4  = buttonH / 2 + buttonH * 3
local posYRow5  = buttonH / 2 + buttonH * 4

local button1       = display.newRect(posXCol1, posYRow1, buttonW, buttonH)
local button2       = display.newRect(posXCol2, posYRow1, buttonW, buttonH)
local button3       = display.newRect(posXCol3, posYRow1, buttonW, buttonH)
local button4       = display.newRect(posXCol1, posYRow2, buttonW, buttonH)
local button5       = display.newRect(posXCol2, posYRow2, buttonW, buttonH)
local button6       = display.newRect(posXCol3, posYRow2, buttonW, buttonH)
local button7       = display.newRect(posXCol1, posYRow3, buttonW, buttonH)
local button8       = display.newRect(posXCol2, posYRow3, buttonW, buttonH)
local button9       = display.newRect(posXCol3, posYRow3, buttonW, buttonH)
local button0       = display.newRect(posXCol2, posYRow4, buttonW, buttonH)
local buttonClear   = display.newRect(posXCol1, posYRow5, buttonW, buttonH)
local buttonCancel  = display.newRect(posXCol2, posYRow5, buttonW, buttonH)
local buttonEnter   = display.newRect(posXCol3, posYRow5, buttonW, buttonH)

local button1Text       = display.newText("1",      posXCol1, posYRow1, native.systemFontBold, fontSize)
local button2Text       = display.newText("2",      posXCol2, posYRow1, native.systemFontBold, fontSize)
local button3Text       = display.newText("3",      posXCol3, posYRow1, native.systemFontBold, fontSize)
local button4Text       = display.newText("4",      posXCol1, posYRow2, native.systemFontBold, fontSize)
local button5Text       = display.newText("5",      posXCol2, posYRow2, native.systemFontBold, fontSize)
local button6Text       = display.newText("6",      posXCol3, posYRow2, native.systemFontBold, fontSize)
local button7Text       = display.newText("7",      posXCol1, posYRow3, native.systemFontBold, fontSize)
local button8Text       = display.newText("8",      posXCol2, posYRow3, native.systemFontBold, fontSize)
local button9Text       = display.newText("9",      posXCol3, posYRow3, native.systemFontBold, fontSize)
local button0Text       = display.newText("0",      posXCol2, posYRow4, native.systemFontBold, fontSize)
local buttonClearText   = display.newText("Clear",  posXCol1, posYRow5, native.systemFontBold, fontSize)
local buttonCancelText  = display.newText("Cancel", posXCol2, posYRow5, native.systemFontBold, fontSize)
local buttonEnterText   = display.newText("Enter",  posXCol3, posYRow5, native.systemFontBold, fontSize)

button1Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button2Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button3Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button4Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button5Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button6Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button7Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button8Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button9Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
button0Text:setFillColor(       23/255, 66/255, 199/255, 0.5 )
buttonClearText:setFillColor(   23/255, 66/255, 199/255, 0.5 )
buttonCancelText:setFillColor(  23/255, 66/255, 199/255, 0.5 )
buttonEnterText:setFillColor(   23/255, 66/255, 199/255, 0.5 )

button1:setFillColor(     1, 1, 1,  alphaGrade1 )
button2:setFillColor(     1, 1, 1,  alphaGrade2 )
button3:setFillColor(     1, 1, 1               )
button4:setFillColor(     1, 1, 1               )
button5:setFillColor(     1, 1, 1,  alphaGrade1 )
button6:setFillColor(     1, 1, 1,  alphaGrade2 )
button7:setFillColor(     1, 1, 1,  alphaGrade2 )
button8:setFillColor(     1, 1, 1               )
button9:setFillColor(     1, 1, 1,  alphaGrade1 )
button0:setFillColor(     1, 1, 1,  alphaGrade1 )
buttonClear:setFillColor( 1, 1, 1,  alphaGrade1 )
buttonCancel:setFillColor(1, 1, 1,  alphaGrade2 )
buttonEnter:setFillColor( 1, 1, 1               )

numPadGroup:insert( button1       )
numPadGroup:insert( button2       )
numPadGroup:insert( button3       )
numPadGroup:insert( button4       )
numPadGroup:insert( button5       )
numPadGroup:insert( button6       )
numPadGroup:insert( button7       )
numPadGroup:insert( button8       )
numPadGroup:insert( button9       )
numPadGroup:insert( button0       )
numPadGroup:insert( buttonClear   )
numPadGroup:insert( buttonCancel  )
numPadGroup:insert( buttonEnter   )

numPadGroup:insert( button1Text       )
numPadGroup:insert( button2Text       )
numPadGroup:insert( button3Text       )
numPadGroup:insert( button4Text       )
numPadGroup:insert( button5Text       )
numPadGroup:insert( button6Text       )
numPadGroup:insert( button7Text       )
numPadGroup:insert( button8Text       )
numPadGroup:insert( button9Text       )
numPadGroup:insert( button0Text       )
numPadGroup:insert( buttonClearText   ) 
numPadGroup:insert( buttonCancelText  )
numPadGroup:insert( buttonEnterText   )

--
--  Functions to handle user input
--

--  Sets the visible numbers on the screen to the digits pressed
local function updateCardNumberDisplay()
  if lockUserEntry == false then
    cardNumDig1Text.text = cardNumber[1]
    cardNumDig2Text.text = cardNumber[2]
    cardNumDig3Text.text = cardNumber[3]
    cardNumDig4Text.text = cardNumber[4]
    cardNumDig5Text.text = cardNumber[5]
    cardNumDig6Text.text = cardNumber[6]
    cardNumDig7Text.text = cardNumber[7]
    cardNumDig8Text.text = cardNumber[8]
  end
end

--  Process incoming digits from the number keys and increment the card 
--  number length in order to know which UI element to update with the newest digit.
--
--  @tparam string digitPressed: The character associated with the listener function who last called
local function cardNumberDisplayHandler(digitPressed)
  if lockUserEntry == false then
    cardNumber[cardNumberdigitsCount] = digitPressed
    cardNumberdigitsCount = cardNumberdigitsCount + 1
    updateCardNumberDisplay()
  else
    print("Input attempt while input locked") -- If a valid carnd number has been entered, or if the transaction has been cancelled, do not allow updates.
  end
end

--  Resets the application when either cancel or clear is pressed by the user, 
--  or the merchant confirms the transaction is complete.
local function resetCardNumber()
  lockUserEntry = false
  for var = 1, 8 do
    cardNumber[var] = "_"
  end
  updateCardNumberDisplay()
  cardNumberdigitsCount = 1
end

-- Increment the progress variable which is used as the percent value for the progress bar and update status text at specified points in the sequence.
local function updateProgressBar()
  progress = progress + 0.1  
  progressView:setProgress(progress)
  if progress > 0.5 then
    status = "Contacting bank."
    statusText.text = status
  end
  if progress > 0.6 then
    status = "Contacting bank.."
    statusText.text = status
  end
  if progress > 0.7 then
    status = "Contacting bank..."
    statusText.text = status
  end
  if progress > 1 then
    status = "Status: Approved"
    statusText.text = status
    statusText:setFillColor(0/255, 107/255, 54/255) --  Set the status text colour to green to indicate success.
  end
  if progress > 1.5 then
    status = "Transaction completed"
    statusText.text = status
  end
end

-- Produce progress bar animation by calling updateProgressBar once a second.
local function animateAcuisition()
  progressView.isVisible = true
  local countDownTimerProgBar = timer.performWithDelay( 1000, updateProgressBar, progress, "acquisitionTimer" )
end

--  Constructs a string out of the digits entered in order to verify number length,
--  hashes the card number if it is the correct length (i.e fully entered).
local function checkCardNumber()

  local fullCardNum = ""

  for var = 1, 8 do
    if string.match(cardNumber[var], "_")  then
      status = "Please enter a valid card number"
      statusText.text = status
    else
      fullCardNum = fullCardNum .. cardNumber[var] 
    end
  end

  if enableUnitTests then
    local test = UnitTest:CardNumberLength(string.len(fullCardNum)) -- No encryption, only length passed in here.
  end

  if string.len(fullCardNum) == 8 then
    lockUserEntry = true
    local hash = crypto.digest( crypto.sha256, fullCardNum ) -- Hashed not encrypted, but in this way at least the data cannot be tampered with without invalidating the signature.
    animateAcuisition()
  end

  cardNumberdigitsCount = 1
end

--  Reset UI elements, card data and timers for animation in the event of user pressing clear. 
local function pushButtonClear()
  status = "Please enter your card details"
  statusText.text = status
  resetCardNumber()
  progressView.isVisible = false
  timer.cancel("acquisitionTimer")
  progress = 0
  progressView:setProgress(progress)
  statusText:setFillColor( 23/255, 66/255, 199/255 )
end

--  Reset UI elements and data variables in the event of user pressing cancel.
local function pushButtonCancel()
  status = "Transaction cancelled"
  statusText.text = status
  resetCardNumber()
  lockUserEntry = true
end

--  Process user-entered data when enter pressed.
local function pushButtonEnter()
  status = "Please return the terminal"
  statusText.text = status
  checkCardNumber()
end

--
--  UI event listener functions.
--
local function pushButton1()
  cardNumberDisplayHandler("1")
end

local function pushButton2()
  cardNumberDisplayHandler("2")
end

local function pushButton3()
cardNumberDisplayHandler("3")
end

local function pushButton4()
  cardNumberDisplayHandler("4")
end

local function pushButton5()
  cardNumberDisplayHandler("5")
end

local function pushButton6()
  cardNumberDisplayHandler("6")
end

local function pushButton7()
  cardNumberDisplayHandler("7")
end

local function pushButton8()
  cardNumberDisplayHandler("8")
end

local function pushButton9()
  cardNumberDisplayHandler("9")
end

local function pushButton0()
  cardNumberDisplayHandler("0")
end

button1:addEventListener(       "tap",  pushButton1       )
button2:addEventListener(       "tap",  pushButton2       )
button3:addEventListener(       "tap",  pushButton3       )
button4:addEventListener(       "tap",  pushButton4       )
button5:addEventListener(       "tap",  pushButton5       )
button6:addEventListener(       "tap",  pushButton6       )
button7:addEventListener(       "tap",  pushButton7       )
button8:addEventListener(       "tap",  pushButton8       )
button9:addEventListener(       "tap",  pushButton9       )
button0:addEventListener(       "tap",  pushButton0       )
buttonClear:addEventListener(   "tap",  pushButtonClear   )
buttonCancel:addEventListener(  "tap",  pushButtonCancel  )
buttonEnter:addEventListener(   "tap",  pushButtonEnter   )

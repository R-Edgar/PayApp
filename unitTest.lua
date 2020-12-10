
-- Table to represent the UnitTest class
UnitTest = {}

--  Validates the correct number of characters have been entered by the user (Should be 8)
--
--  @tparam int cardNumberLength: string.len(cardNumber)
function UnitTest:CardNumberLength( cardNumberLength )
    assert( cardNumberLength == 8,  "Expected 8 characters, got " .. cardNumberLength)
end
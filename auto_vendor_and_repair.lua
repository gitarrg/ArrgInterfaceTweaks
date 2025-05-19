


local function auto_repair()
	local cost, canRepair = GetRepairAllCost()
	if canRepair and cost > 0 then
		RepairAllItems()
	end
end


local function vendor_greys()
	C_MerchantFrame.SellAllJunkItems()
	-- SellAllJunkItems()
end


local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")

eventFrame:SetScript("OnEvent", function(event, ...)
	if event == "MERCHANT_SHOW" then
		auto_repair()
		vendor_greys()
	end
end)


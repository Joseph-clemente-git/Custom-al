query 70145 "MJS Items By Location API"
{
    // Backs majesty-pharma-web's item lookup (fetchBcItemsByLocation in
    // lib/server/bc.ts): one row per item + location, with "inventory" as the
    // real physical stock for that item/location. Only PUTPICK (pick face)
    // bins count toward that stock, mirroring how the standard "Bin Contents"
    // page (Location Filter + Bin Type Code = PUTPICK) is used to see what is
    // actually available to pick — bulk/reserve bin types are excluded so the
    // figure reflects real, pickable stock rather than total on-hand across
    // every storage bin. An item with no PUTPICK bin content at a location is
    // left out entirely (inner join), not returned with a zero quantity.
    Caption = 'Items by Location API';
    QueryType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityName = 'itemsByLocation';
    EntitySetName = 'itemsByLocation';

    elements
    {
        dataitem(Item; Item)
        {
            column(itemNo; "No.")
            {
            }
            column(description; Description)
            {
            }
            column(blocked; Blocked)
            {
            }
            column(baseUnitOfMeasure; "Base Unit of Measure")
            {
            }
            column(unitPrice; "Unit Price")
            {
            }
            column(unitCost; "Unit Cost")
            {
            }
            column(itemCategoryCode; "Item Category Code")
            {
            }
            column(itemType; Type)
            {
            }
            column(profitPercent; "Profit %")
            {
            }
            column(shelfNo; "Shelf No.")
            {
            }
            column(unitVolume; "Unit Volume")
            {
            }
            column(stockoutWarning; "Stockout Warning")
            {
            }
            column(variantMandatoryIfExists; "Variant Mandatory if Exists")
            {
            }
            column(overReceiptCode; "Over-Receipt Code")
            {
            }
            column(salesUnitOfMeasure; "Sales Unit of Measure")
            {
            }
            column(salesBlocked; "Sales Blocked")
            {
            }
            column(replenishmentSystem; "Replenishment System")
            {
            }
            column(leadTimeCalculation; "Lead Time Calculation")
            {
            }
            column(vendorNo; "Vendor No.")
            {
            }
            column(vendorItemNo; "Vendor Item No.")
            {
            }
            column(purchUnitOfMeasure; "Purch. Unit of Measure")
            {
            }
            column(purchasingBlocked; "Purchasing Blocked")
            {
            }
            column(assemblyPolicy; "Assembly Policy")
            {
            }
            column(reorderingPolicy; "Reordering Policy")
            {
            }
            column(orderTrackingPolicy; "Order Tracking Policy")
            {
            }
            column(critical; Critical)
            {
            }
            column(safetyLeadTime; "Safety Lead Time")
            {
            }
            column(safetyStockQuantity; "Safety Stock Quantity")
            {
            }
            column(includeInventory; "Include Inventory")
            {
            }
            column(lotAccumulationPeriod; "Lot Accumulation Period")
            {
            }
            column(reschedulingPeriod; "Rescheduling Period")
            {
            }
            column(reorderPoint; "Reorder Point")
            {
            }
            column(reorderQuantity; "Reorder Quantity")
            {
            }
            column(maximumInventory; "Maximum Inventory")
            {
            }
            column(minimumOrderQuantity; "Minimum Order Quantity")
            {
            }
            column(maximumOrderQuantity; "Maximum Order Quantity")
            {
            }
            column(orderMultiple; "Order Multiple")
            {
            }
            column(itemTrackingCode; "Item Tracking Code")
            {
            }
            column(serialNos; "Serial Nos.")
            {
            }
            column(lotNos; "Lot Nos.")
            {
            }
            column(expirationCalculation; "Expiration Calculation")
            {
            }
            column(warehouseClassCode; "Warehouse Class Code")
            {
            }
            column(putAwayTemplateCode; "Put-away Template Code")
            {
            }
            column(putAwayUnitOfMeasureCode; "Put-away Unit of Measure Code")
            {
            }
            column(physInvtCountingPeriodCode; "Phys Invt Counting Period Code")
            {
            }
            column(lastCountingPeriodUpdate; "Last Counting Period Update")
            {
            }
            column(nextCountingStartDate; "Next Counting Start Date")
            {
            }
            column(nextCountingEndDate; "Next Counting End Date")
            {
            }

            dataitem(BinContent; "Bin Content")
            {
                DataItemLink = "Item No." = Item."No.";
                DataItemTableFilter = "Bin Type Code" = const('PUTPICK');

                column(locationCode; "Location Code")
                {
                }
                column(inventory; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}

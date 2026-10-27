query 70110 "MJS Lot No. Info API"
{
    // Backs Purchase Order receiving in majesty-pharma-web: the Lot Nos.
    // (batches) that already exist for an item — BC's Lot No. Information
    // cards, Blocked ones left out — because a receipt may only use an
    // existing lot, never create one (fetchBcLotNoInformation in
    // lib/server/bc.ts). expirationDate is the expiry already posted for the
    // lot on Item Ledger Entry, one row per lot and expiry; blank (0D) when
    // nothing has been posted yet. remainingQuantity is the lot's inventory
    // (Item Ledger Entry Remaining Quantity, all locations) in the item's
    // base unit of measure — the same sum as Lot No. Information's Inventory.
    Caption = 'Lot No. Information API';
    QueryType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityName = 'lotNoInformation';
    EntitySetName = 'lotNoInformations';

    elements
    {
        dataitem(LotNoInformation; "Lot No. Information")
        {
            DataItemTableFilter = Blocked = const(false);

            column(itemNo; "Item No.")
            {
            }
            column(variantCode; "Variant Code")
            {
            }
            column(lotNo; "Lot No.")
            {
            }
            column(description; Description)
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = LotNoInformation."Item No.";
                SqlJoinType = InnerJoin;

                column(baseUnitOfMeasure; "Base Unit of Measure")
                {
                }
                dataitem(ItemLedgerEntry; "Item Ledger Entry")
                {
                    DataItemLink = "Item No." = LotNoInformation."Item No.", "Variant Code" = LotNoInformation."Variant Code", "Lot No." = LotNoInformation."Lot No.";
                    SqlJoinType = LeftOuterJoin;

                    column(expirationDate; "Expiration Date")
                    {
                    }
                    // Sum groups the rows: one per lot and posted expiry.
                    column(remainingQuantity; "Remaining Quantity")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}

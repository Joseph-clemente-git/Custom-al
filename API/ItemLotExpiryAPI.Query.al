query 70109 "MJS Item Lot Expiry API"
{
    // Backs the stock status colours in majesty-pharma-web's Sales Order item
    // picker and order lines (fetchBcItemLotExpiry in lib/server/bc.ts): the
    // pickable quantity per item / variant / location / lot with that lot's
    // Expiration Date, so the web app can flag near-expiry and expired stock.
    // Counts the same PUTPICK (pick face) bins as "MJS Items By Location API",
    // summed from Warehouse Entry because Bin Content carries no lot or
    // expiration data. Lots whose PUTPICK entries net to zero are left out.
    Caption = 'Item Lot Expiry API';
    QueryType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityName = 'itemLotExpiry';
    EntitySetName = 'itemLotExpiries';

    elements
    {
        dataitem(WarehouseEntry; "Warehouse Entry")
        {
            DataItemTableFilter = "Bin Type Code" = const('PUTPICK');

            column(itemNo; "Item No.")
            {
            }
            column(variantCode; "Variant Code")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(lotNo; "Lot No.")
            {
            }
            column(expirationDate; "Expiration Date")
            {
            }
            column(quantityBase; "Qty. (Base)")
            {
                Method = Sum;
                ColumnFilter = quantityBase = filter(<> 0);
            }
        }
    }
}

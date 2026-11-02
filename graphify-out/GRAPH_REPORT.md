# Graph Report - Custom-al  (2026-10-31)

## Corpus Check
- Corpus is ~119 words - fits in a single context window. You may not need a graph.

## Summary
- 183 nodes · 347 edges · 10 communities (9 shown, 1 thin omitted)
- Extraction: 92% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 26 edges (avg confidence: 0.83)
- Token cost: 249,462 input · 0 output

## Community Hubs (Navigation)
- Master Data & Pricing APIs
- Warehouse Movements
- Warehouse Receipts & Posting
- Sales Order Campaign API
- Warehouse Pick Management
- AL App Manifest
- Pick Lot Selection
- Item Lot & Location Queries
- Item UOM APIs
- Extension README

## God Nodes (most connected - your core abstractions)
1. `PermissionSet 70137 GMPI MJS Whse. API (MJS Warehouse API)` - 58 edges
2. `BC Table Warehouse Activity Line` - 26 edges
3. `Page 70119 MJS Sales Order Campaign API (majesty/wms/v1.0/salesOrderCampaigns)` - 20 edges
4. `Codeunit 70132 MJS Whse. Pick Mgt.` - 18 edges
5. `MJS Whse. Receipt Lot Mgt.AssignLots()` - 14 edges
6. `MJS Whse. Pick Mgt.FillPickLots()` - 10 edges
7. `MJS Whse. Pick Mgt.CreatePick()` - 9 edges
8. `Codeunit 70134 MJS Whse. Put-away Mgt.` - 9 edges
9. `BC Table Warehouse Activity Header` - 8 edges
10. `Codeunit 70135 MJS Whse. Movement Mgt.` - 8 edges

## Surprising Connections (you probably didn't know these)
- `MJS Whse. Movement Mgt.SetPlaceBinIfBlank()` --semantically_similar_to--> `MJS Whse. Pick Mgt.SetTakeBinIfBlank()`  [INFERRED] [semantically similar]
  _GMPI MJS Whse. Movement Mgt._.Codeunit.al → _GMPI MJS Whse. Pick Mgt._.Codeunit.al
- `MJS Whse. Receipt Lot Mgt.AssignLots()` --semantically_similar_to--> `MJS Whse. Pick Mgt.AssignLots()`  [INFERRED] [semantically similar]
  _GMPI MJS Whse. Receipt Lot Mgt._.Codeunit.al → _GMPI MJS Whse. Pick Mgt._.Codeunit.al
- `MJS Whse. Movement Mgt.DistributeQty()` --semantically_similar_to--> `MJS Whse. Pick Mgt.DistributeQty()`  [INFERRED] [semantically similar]
  _GMPI MJS Whse. Movement Mgt._.Codeunit.al → _GMPI MJS Whse. Pick Mgt._.Codeunit.al
- `MJS Whse. Put-away Mgt.DistributeQty()` --semantically_similar_to--> `MJS Whse. Pick Mgt.DistributeQty()`  [INFERRED] [semantically similar]
  _GMPI MJS Whse. Put-away Mgt._.Codeunit.al → _GMPI MJS Whse. Pick Mgt._.Codeunit.al
- `PermissionSet 70137 GMPI MJS Whse. API (MJS Warehouse API)` --references--> `Codeunit 70136 MJS Whse. Receipt Lot Mgt.`  [AMBIGUOUS]
  _GMPI MJS Whse. API_.PermissionSet.al → _GMPI MJS Whse. Receipt Lot Mgt._.Codeunit.al

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **JSON-driven warehouse activity registration (zero, distribute Qty. to Handle, Whse.-Activity-Register)** — _gmpi_mjs_whse__pick_mgt___codeunit_registerpick, _gmpi_mjs_whse__movement_mgt___codeunit_registermovement, _gmpi_mjs_whse__put_away_mgt___codeunit_registerputaway, bc_codeunit_whse_activity_register, bc_table_warehouse_activity_line [INFERRED 0.95]
- **Lot tracking for web app (pick lots, receipt lots, lot info/expiry queries)** — _gmpi_mjs_whse__pick_mgt___codeunit_fillpicklots, _gmpi_mjs_pick_lot_buffer__table, _gmpi_mjs_whse__receipt_lot_mgt___codeunit_assignlots, _gmpi_mjs_lot_no__info_api__query, _gmpi_mjs_item_lot_expiry_api__query [INFERRED 0.85]
- **PUTPICK pickable-stock API queries** — _gmpi_mjs_item_lot_expiry_api__query, _gmpi_mjs_items_by_location_api__query, bc_bin_type_putpick, majesty_pharma_web_lib_server_bc [INFERRED 0.85]
- **Warehouse Activity header/line API family (movement, pick, put-away)** — _gmpi_mjs_whse__movement_api__page, _gmpi_mjs_whse__movement_line_api__page, _gmpi_mjs_whse__pick_api__page, _gmpi_mjs_whse__pick_line_api__page, _gmpi_mjs_whse__put_away_api__page, _gmpi_mjs_whse__put_away_line_api__page [INFERRED 0.85]
- **Outbound flow: shipment create pick, register pick, post shipment, posted shipment history** — _gmpi_mjs_whse__shipment_api__page_createpick, _gmpi_mjs_whse__shipment_api__page_registerpick, _gmpi_mjs_whse__shipment_api__page_postshipment, _gmpi_mjs_posted_whse__shpt__api__page, _gmpi_mjs_posted_whse__shpt_line_api__page, _gmpi_mjs_pick_lot_api__page [INFERRED 0.85]
- **Inbound flow: receipt assign lots, post receipt, register put-away** — _gmpi_mjs_whse__receipt_api__page_assignlots, _gmpi_mjs_whse__receipt_api__page_postreceipt, _gmpi_mjs_whse__receipt_line_api__page, _gmpi_mjs_whse__put_away_api__page_registerputaway [INFERRED 0.85]
- **Web app sales price/discount resolution APIs** — _gmpi_mjs_sales_price_api__page, _gmpi_mjs_sales_line_discount_api__page, _gmpi_mjs_sales_price_customer_api__page [INFERRED 0.85]
- **Web Sales Order creation flow (pickers + header/line actions + release)** — _gmpi_mjs_campaign_api__page, _gmpi_mjs_ship_to_address_api__page, _gmpi_mjs_item_variant_api__page, _gmpi_mjs_item_uom_api__page, _gmpi_mjs_vat_bus__post__group_api__page, _gmpi_mjs_sales_order_campaign_api__page [INFERRED 0.85]
- **Sales order release/reopen via Release Sales Document** — _gmpi_mjs_sales_order_campaign_api__page_release, _gmpi_mjs_sales_order_campaign_api__page_setresponsibilitycenter, _gmpi_mjs_sales_order_campaign_api__page_setshipmentmethod, _gmpi_mjs_sales_order_campaign_api__page_setlinelocation, _gmpi_mjs_sales_order_repair_api__page_reopen, bc_codeunit_release_sales_document [EXTRACTED 1.00]

## Communities (10 total, 1 thin omitted)

### Community 0 - "Master Data & Pricing APIs"
Cohesion: 0.07
Nodes (41): Page 70113 MJS Bin API (API majesty/wms/v1.0 bins), Page 70114 MJS Bin Content API (API majesty/wms/v1.0 binContents), Page 70115 MJS Campaign API (majesty/wms/v1.0/campaigns), Page 70117 MJS Item Reference API (majesty/wms/v1.0/itemReferences), Page 70147 MJS Posted Whse. Shpt. API (API majesty/wms/v1.0 postedWarehouseShipments), Page 70148 MJS Posted Whse. Shpt Line API (API majesty/wms/v1.0 postedWarehouseShipmentLines), Page 70144 MJS Sales Line Discount API (majesty/wms/v1.0/salesLineDiscounts), MJS Sales Line Discount API OnAfterGetRecord (+33 more)

### Community 1 - "Warehouse Movements"
Cohesion: 0.15
Nodes (26): Page 70123 MJS Whse. Movement API (API majesty/wms/v1.0 warehouseMovements), MJS Whse. Movement API.registerMovement(), Page 70124 MJS Whse. Movement Line API (API majesty/wms/v1.0 warehouseMovementLines), Codeunit 70135 MJS Whse. Movement Mgt., MJS Whse. Movement Mgt.ApplyQuantities(), MJS Whse. Movement Mgt.AutofillQtyToHandle(), MJS Whse. Movement Mgt.DistributeQty(), MJS Whse. Movement Mgt.GetJsonText() (+18 more)

### Community 2 - "Warehouse Receipts & Posting"
Cohesion: 0.14
Nodes (26): Query 70110 MJS Lot No. Info API (/api/majesty/wms/v1.0/lotNoInformations), MJS Whse. Pick Line API.OnAfterGetRecord(), Codeunit 70133 MJS Whse. Post Mgt., MJS Whse. Post Mgt.PostReceipt(), Page 70129 MJS Whse. Receipt API (API majesty/wms/v1.0 warehouseReceipts), MJS Whse. Receipt API.assignLots(), MJS Whse. Receipt API.postReceipt(), Page 70130 MJS Whse. Receipt Line API (API majesty/wms/v1.0 warehouseReceiptLines) (+18 more)

### Community 3 - "Sales Order Campaign API"
Cohesion: 0.14
Nodes (22): Page 70141 MJS Item Variant API (majesty/wms/v1.0/itemVariants), Page 70119 MJS Sales Order Campaign API (majesty/wms/v1.0/salesOrderCampaigns), MJS Sales Order Campaign API addItemLine [ServiceEnabled], MJS Sales Order Campaign API AddItemLineInternal (local), MJS Sales Order Campaign API addItemVariantLine [ServiceEnabled], MJS Sales Order Campaign API release [ServiceEnabled], MJS Sales Order Campaign API SetCommentLines (local), MJS Sales Order Campaign API setLineLocation [ServiceEnabled] (+14 more)

### Community 4 - "Warehouse Pick Management"
Cohesion: 0.16
Nodes (21): Codeunit 70132 MJS Whse. Pick Mgt., MJS Whse. Pick Mgt.ApplyQuantities(), MJS Whse. Pick Mgt.AssignLots(), MJS Whse. Pick Mgt.AssignLotsToLines(), MJS Whse. Pick Mgt.AutofillQtyToHandle(), MJS Whse. Pick Mgt.CreatePick(), MJS Whse. Pick Mgt.DistributeQty(), MJS Whse. Pick Mgt.FindPick() (+13 more)

### Community 5 - "AL App Manifest"
Cohesion: 0.11
Nodes (18): application, build, by, dependencies, features, id, idRanges, name (+10 more)

### Community 6 - "Pick Lot Selection"
Cohesion: 0.20
Nodes (10): Page 70106 MJS Pick Lot API (API majesty/wms/v1.0 pickLots), MJS Pick Lot API.OnFindRecord(), Table 70104 MJS Pick Lot Buffer, Page 70125 MJS Whse. Pick API (API majesty/wms/v1.0 warehousePicks), Page 70126 MJS Whse. Pick Line API (API majesty/wms/v1.0 warehousePickLines), MJS Whse. Pick Mgt.FillPickLots(), BC Codeunit Item Tracking Data Collection, BC Table Entry Summary (+2 more)

### Community 7 - "Item Lot & Location Queries"
Cohesion: 0.47
Nodes (6): Query 70109 MJS Item Lot Expiry API (/api/majesty/wms/v1.0/itemLotExpiries), Query 70145 MJS Items By Location API (/api/majesty/wms/v1.0/itemsByLocation), MJS Whse. Pick Mgt.LotQtyInUoM(), PUTPICK bin type (pick face bins), BC Table Warehouse Entry, majesty-pharma-web lib/server/bc.ts (BC API client)

### Community 8 - "Item UOM APIs"
Cohesion: 0.33
Nodes (6): Page 70118 MJS Item UOM API (majesty/wms/v1.0/itemUnitOfMeasures), MJS Item UOM API OnAfterGetRecord, PageExtension 70136 MJS Sales Order UOM (extends Sales Order Subform), BC Page Sales Order Subform, BC Table Item Unit of Measure, BC Table Unit of Measure

## Ambiguous Edges - Review These
- `Codeunit 70136 MJS Whse. Receipt Lot Mgt.` → `PermissionSet 70137 GMPI MJS Whse. API (MJS Warehouse API)`  [AMBIGUOUS]
  _GMPI MJS Whse. API_.PermissionSet.al · relation: references

## Knowledge Gaps
- **22 isolated node(s):** `Custom-al README (Majesty BC AL extension)`, `BC Table Tracking Specification`, `BC Table Entry Summary`, `BC Codeunit Whse.-Shipment Release`, `BC Report Whse.-Shipment - Create Pick` (+17 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 43 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PermissionSet 70137 GMPI MJS Whse. API (MJS Warehouse API)` connect `Master Data & Pricing APIs` to `Warehouse Movements`, `Warehouse Receipts & Posting`, `Sales Order Campaign API`, `Warehouse Pick Management`, `Pick Lot Selection`, `Item Lot & Location Queries`, `Item UOM APIs`?**
  _High betweenness centrality (0.604) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `MJS Whse. Receipt Lot Mgt.AssignLots()` (e.g. with `Query 70110 MJS Lot No. Info API (/api/majesty/wms/v1.0/lotNoInformations)` and `MJS Whse. Pick Mgt.AssignLots()`) actually correct?**
  _`MJS Whse. Receipt Lot Mgt.AssignLots()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Custom-al README (Majesty BC AL extension)`, `BC Table Tracking Specification`, `BC Table Entry Summary` to the rest of the system?**
  _22 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Master Data & Pricing APIs` be split into smaller, more focused modules?**
  _Cohesion score 0.0743321718931475 - nodes in this community are weakly interconnected._
- **Why does `Codeunit 70132 MJS Whse. Pick Mgt.` connect `Warehouse Pick Management` to `Master Data & Pricing APIs`, `Warehouse Movements`, `Pick Lot Selection`, `Item Lot & Location Queries`?**
  _High betweenness centrality (0.146) - this node is a cross-community bridge._
- **Should `Warehouse Receipts & Posting` be split into smaller, more focused modules?**
  _Cohesion score 0.13846153846153847 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Codeunit 70136 MJS Whse. Receipt Lot Mgt.` and `PermissionSet 70137 GMPI MJS Whse. API (MJS Warehouse API)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
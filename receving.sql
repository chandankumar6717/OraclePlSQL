http://www.oraclecafe.com/2015/09/receiving-transaction-processor-transfer/


DECLARE
   ln_to_subinventory   VARCHAR2 (3) := 'XYZ';
   ln_to_locator_id     NUMBER := 101010;
BEGIN
   FOR j
      IN (  SELECT rsh.shipment_header_id,
                   rsl.shipment_line_id,
                   rsh.vendor_id,
                   receipt_num,
                   expected_receipt_date,
                   rsh.ship_to_org_id,
                   rsl.item_id,
                   rsl.source_document_code,
                   rsl.po_header_id,
                   rsl.po_line_id,
                   rsl.po_line_location_id,
                   rsl.primary_unit_of_measure,
                   rt.transaction_id,
                   rt.quantity,
                   rt.interface_source_code,
                   rt.transaction_type,
                   rt.location_id,
                   rt.from_subinventory,
                   rt.from_locator_id,
                   rt.lpn_id,
                   rt.transfer_lpn_id,
                   rsl.destination_type_code
              FROM rcv_shipment_headers rsh,
                   rcv_shipment_lines rsl,
                   rcv_transactions rt
             WHERE     1 = 1
                   AND receipt_num = :pn_receipt_number
                   AND rsl.shipment_header_id = rsh.shipment_header_id
                   AND rt.shipment_header_id = rsh.shipment_header_id
                   AND rt.shipment_line_id = rsl.shipment_line_id
                   AND NOT EXISTS
                              (SELECT *
                                 FROM rcv_transactions rt1
                                WHERE     1 = 1
                                      AND rt1.shipment_header_id =
                                             rt.shipment_header_id
                                      AND rt1.shipment_line_id =
                                             rt.shipment_line_id
                                      AND rt1.po_header_id = rt.po_header_id
                                      AND rt1.po_line_id = rt.po_line_id
                                      AND rt1.po_line_location_id =
                                             rt.po_line_location_id
                                      AND rt.transaction_type = 'DELIVER')
          ORDER BY 1)
   LOOP
      INSERT INTO rcv_transactions_interface (interface_transaction_id,
                                              GROUP_ID,
                                              last_update_date,
                                              last_updated_by,
                                              creation_date,
                                              created_by,
                                              transaction_type,
                                              transaction_date,
                                              processing_status_code,
                                              processing_mode_code,
                                              transaction_status_code,
                                              shipment_header_id,
                                              shipment_line_id,
                                              item_id,
                                              quantity,
                                              unit_of_measure,
                                              interface_source_code,
                                              po_line_location_id,
                                              auto_transact_code,
                                              receipt_source_code,
                                              to_organization_id,
                                              source_document_code,
                                              destination_type_code,
                                              destination_context,
                                              header_interface_id,
                                              vendor_id,
                                              subinventory,
                                              locator_id,
                                              validation_flag,
                                              lpn_id,
                                              transfer_lpn_id,
                                              parent_transaction_id,
                                              from_subinventory,
                                              from_locator_id)
           VALUES (rcv_transactions_interface_s.NEXTVAL, -- INTERFACE TRANSATION_ID
                   rcv_interface_groups_s.NEXTVAL,                  --GROUP ID
                   SYSDATE,                                -- LAST UPDATE DATE
                   fnd_global.user_id,                        --LAST UPDATE BY
                   SYSDATE,                                   -- CREATION DATE
                   fnd_global.user_id,                           -- CREATED BY
                   'TRANSFER',                             -- TRANSACTION TYPE
                   SYSDATE,                                -- TRANSACTION DATE
                   'PENDING',                        -- PROCESSING_STATUS_CODE
                   'BATCH',                             --PROCESSING_MODE_CODE
                   'PENDING',                        --TRANSACTION_STATUS_CODE
                   j.shipment_header_id,                  --SHIPMENT HEADER ID
                   j.shipment_line_id,                      --SHIPMENT LINE ID
                   j.item_id,                                        --ITEM ID
                   j.quantity,                                     --quantity,
                   j.primary_unit_of_measure,                --UNIT OF MEASURE
                   j.interface_source_code,           --INTERFACE_SOURCE_CODE,
                   j.po_line_location_id,
                   'TRANSFER',                            --AUTO_TRANSACT_CODE
                   'VENDOR',                                       --VENDOR ID
                   j.ship_to_org_id,                    --  TO_ORGANIZATION_ID
                   j.source_document_code,
                   j.destination_type_code,            --DESTINATION_TYPE_CODE
                   j.destination_type_code,              --DESTINATION_CONTEXT
                   NULL,                                 --HEADER INTERFACE ID
                   j.vendor_id,                                    --VENDOR ID
                   ln_to_subinventory,                   -- TO SUBINVENTORY ID
                   ln_to_locator_id,                          -- TO LOCATOR ID
                   'Y',                                     -- VALIDATION FLAG
                   j.lpn_id,                                          --LPN ID
                   j.transfer_lpn_id,                        --TRANSFER LPN ID
                   j.transaction_id,                  -- PARENT TRANSACTION ID
                   j.from_subinventory,                -- FROM SUBINVENTORY ID
                   j.from_locator_id);                      -- FROM LOCATOR ID
   END LOOP;
END;

CREATE OR REPLACE PACKAGE OrderPackage AS
  PROCEDURE ProcessOrderXML(p_order_xml CLOB);
  FUNCTION GetOrderItems(p_order_id NUMBER) RETURN SYS_REFCURSOR;
END OrderPackage;
/

CREATE OR REPLACE PACKAGE BODY OrderPackage AS

  -- Procedimento para processar o XML do pedido
  PROCEDURE ProcessOrderXML(p_order_xml CLOB) IS
    v_order_id    NUMBER;
    v_customer_name VARCHAR2(100);
    v_order_date   DATE;

    -- Cursor para garantir que não haja produtos duplicados
CURSOR c_check_duplicate IS
SELECT COUNT(1)
FROM OrderItems
WHERE OrderId = v_order_id
  AND ProductName = v_product_name;

-- Variáveis de produto
v_product_name VARCHAR2(100);
    v_quantity     NUMBER;
    v_price        NUMBER;

BEGIN
    -- Parse do XML usando XMLTable
SELECT x.CustomerName, TO_DATE(x.OrderDate, 'YYYY-MM-DD')
INTO v_customer_name, v_order_date
FROM XMLTable(
             '/Order' PASSING XMLType(p_order_xml)
      COLUMNS
        CustomerName VARCHAR2(100) PATH 'CustomerName',
             OrderDate    VARCHAR2(10) PATH 'OrderDate'
     ) x;

-- Inserir o pedido na tabela Orders
INSERT INTO Orders (OrderId, CustomerName, OrderDate)
VALUES (Orders_seq.NEXTVAL, v_customer_name, v_order_date)
    RETURNING OrderId INTO v_order_id;

-- Processar os itens do pedido
FOR r_item IN (
      SELECT x.ProductName, x.Quantity, x.Price
      FROM XMLTable(
        '/Order/Items/Item' PASSING XMLType(p_order_xml)
        COLUMNS
          ProductName VARCHAR2(100) PATH 'ProductName',
          Quantity    NUMBER PATH 'Quantity',
          Price       NUMBER PATH 'Price'
      ) x
    ) LOOP
      v_product_name := r_item.ProductName;
      v_quantity := r_item.Quantity;
      v_price := r_item.Price;

      -- Verificar se o produto já existe no pedido
OPEN c_check_duplicate;
FETCH c_check_duplicate INTO v_count;
CLOSE c_check_duplicate;

IF v_count = 0 THEN
        -- Inserir o item na tabela OrderItems
        INSERT INTO OrderItems (OrderItemId, OrderId, ProductName, Quantity, Price)
        VALUES (OrderItems_seq.NEXTVAL, v_order_id, v_product_name, v_quantity, v_price);
ELSE
        -- Levantar exceção se houver duplicação
        RAISE_APPLICATION_ERROR(-20001, 'Produto duplicado encontrado: ' || v_product_name);
END IF;
END LOOP;
END ProcessOrderXML;

  -- Função para retornar todos os itens de um pedido usando SYS_REFCURSOR
  FUNCTION GetOrderItems(p_order_id NUMBER) RETURN SYS_REFCURSOR IS
    v_ref_cursor SYS_REFCURSOR;
BEGIN
OPEN v_ref_cursor FOR
SELECT ProductName, Quantity, Price
FROM OrderItems
WHERE OrderId = p_order_id;
RETURN v_ref_cursor;
END GetOrderItems;

END OrderPackage;
/

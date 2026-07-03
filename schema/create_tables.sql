
CREATE TABLE IF NOT EXISTS public.category
(
    category_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    category_name character varying(20) COLLATE pg_catalog."default",
    CONSTRAINT category_pkey PRIMARY KEY (category_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.category
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.products
(
    product_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    product_name character varying(35) COLLATE pg_catalog."default",
    category_id character varying(10) COLLATE pg_catalog."default",
    launch_date date,
    price double precision,
    CONSTRAINT products_pkey PRIMARY KEY (product_id),
    CONSTRAINT fk_category FOREIGN KEY (category_id)
        REFERENCES public.category (category_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.products
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.sales
(
    sale_id character varying(15) COLLATE pg_catalog."default" NOT NULL,
    sale_date date,
    store_id character varying(10) COLLATE pg_catalog."default",
    product_id character varying(10) COLLATE pg_catalog."default",
    quantity integer,
    CONSTRAINT sales_pkey PRIMARY KEY (sale_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id)
        REFERENCES public.products (product_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_store FOREIGN KEY (store_id)
        REFERENCES public.stores (store_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sales
    OWNER to postgres;
-- Index: sales_product_id

-- DROP INDEX IF EXISTS public.sales_product_id;

CREATE INDEX IF NOT EXISTS sales_product_id
    ON public.sales USING btree
    (product_id COLLATE pg_catalog."default" ASC NULLS LAST)
    WITH (fillfactor=100, deduplicate_items=True)
    TABLESPACE pg_default;
-- Index: sales_sale_date

-- DROP INDEX IF EXISTS public.sales_sale_date;

CREATE INDEX IF NOT EXISTS sales_sale_date
    ON public.sales USING btree
    (sale_id COLLATE pg_catalog."default" ASC NULLS LAST)
    WITH (fillfactor=100, deduplicate_items=True)
    TABLESPACE pg_default;
-- Index: sales_store_id

-- DROP INDEX IF EXISTS public.sales_store_id;

CREATE INDEX IF NOT EXISTS sales_store_id
    ON public.sales USING btree
    (store_id COLLATE pg_catalog."default" ASC NULLS LAST)
    WITH (fillfactor=100, deduplicate_items=True)
    TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS public.stores
(
    store_id character varying(5) COLLATE pg_catalog."default" NOT NULL,
    store_name character varying(30) COLLATE pg_catalog."default",
    city character varying(25) COLLATE pg_catalog."default",
    country character varying(25) COLLATE pg_catalog."default",
    CONSTRAINT stores_pkey PRIMARY KEY (store_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.stores
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.warranty
(
    claim_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    claim_date date,
    sale_id character varying(15) COLLATE pg_catalog."default",
    repair_status character varying(15) COLLATE pg_catalog."default",
    CONSTRAINT warranty_pkey PRIMARY KEY (claim_id),
    CONSTRAINT fk_orders FOREIGN KEY (sale_id)
        REFERENCES public.sales (sale_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.warranty
    OWNER to postgres;
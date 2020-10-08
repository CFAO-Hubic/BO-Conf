Class CFAO.test
{

ClassMethod test() As %Status
{
    set data = {}
    set data.id = 1

    &sql(
        SELECT
            ID
        INTO
            :data.id
        FROM CFAO_HUBIC_BofficeConf_tables.forex
        WHERE
            1 = 1
    )

    // (CASE WHEN ISNULL(:data.test) THEN "ID" = 2 ELSE 1 END)

    if 1 = 1 {return (
           1 = 1
        || 1 = 1
    )}
}

}

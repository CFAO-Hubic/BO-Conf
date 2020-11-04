Class CFAO.HUBIC.BofficeConf.functions.historization Extends Ens.Rule.FunctionSet
{

ClassMethod historize() As %Status
{
	set request =
		   "SELECT DISTINCT(tradeDate)"
		_ " FROM CFAO_HUBIC_BofficeConf_tables.forex"
		_ " WHERE"
			_ " historized = 0"
			_ " AND tradeDate IS NOT NULL"

	set tradeDates = ##class(CFAO.HUBIC.Outils).queryJSON(request)
	set i = tradeDates.%GetIterator()

	while i.%GetNext(.key, .row) {
		set tSC = ..processRow(row)
	}

	return 1
}

ClassMethod processRow(row) As %Status
{
	set tradeDate = row.tradeDate
	
	set all = ..getAll(tradeDate)
	set matched = ..getMatch(tradeDate)

	if all && (matched = all) {
		set tSC = ..makeFile(tradeDate)
	}

	return 1
}

ClassMethod getMatch(tradeDate) As %Status
{
	&sql(
		SELECT COUNT(distinct(idForex))
		INTO :matched
		FROM CFAO_HUBIC_BofficeConf_tables.forex
		WHERE
			tradeDate = :tradeDate
			AND matchStatus = 1
			AND historized = 0
	)

	return matched
}

ClassMethod getAll(tradeDate) As %Status
{
	&sql(
		SELECT COUNT(distinct(idForex))
		INTO :all
		FROM CFAO_HUBIC_BofficeConf_tables.forex
		WHERE
			tradeDate = :tradeDate
			AND historized = 'NON'
	)

	return all
}

ClassMethod makeFile(tradeDate) As %Status
{
	set request =
		   "SELECT"
				_ " ID"
				_ ",idForex"
				_ ",bank"
				_ ",tradeType"
				_ ",amountReceived"
				_ ",deviseReceived"
				_ ",amountPaid"
				_ ",devisePaid"
				_ ",tradeDate"
				_ ",valueDate"
				_ ",maturityDate"
				_ ",spot"
				_ ",term"
		_ " FROM CFAO_HUBIC_BofficeConf_tables.forex"
		_ " WHERE"
			_ " historized = 0"
			_ " AND tradeDate IS NOT NULL"

	set row = ""
	set tradeDates = ##class(CFAO.HUBIC.Outils).queryJSON(request)
	set i = tradeDates.%GetIterator()

	while i.%GetNext(.key, .row) {
		set j = row.%GetIterator()
		
		while j.%GetNext(.key2, .field) {
			set row = row _ ";" _ field
		}
	}

	return 1
}

}

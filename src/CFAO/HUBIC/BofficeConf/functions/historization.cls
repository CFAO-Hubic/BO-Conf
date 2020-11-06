Class CFAO.HUBIC.BofficeConf.functions.historization Extends Ens.Rule.FunctionSet
{

ClassMethod historize() As %Status
{
	set ^boConfRecapFilePath = "D:\HUBIC\BackOfficeConf\FichierRecapCSV"
	set errors = []

	set request =
		   "SELECT DISTINCT(tradeDate)"
		_ " FROM CFAO_HUBIC_BofficeConf_tables.forex"
		_ " WHERE"
			_ " historized = 0"
			_ " AND tradeDate IS NOT NULL"

	set tradeDates = ##class(CFAO.HUBIC.Outils).queryJSON(request)
	set i = tradeDates.%GetIterator()

	while i.%GetNext(.key, .row) {
		set tSC = ..processDate(row)
		do:'tSC errors.%Push(row.tradeDate)
	}

	return:errors.%Size() errors.%ToJSON()
	return 1
}

ClassMethod processDate(row) As %Status
{
	set tradeDate = row.tradeDate
	
	set all = ..getAll(tradeDate)
	set matched = ..getMatch(tradeDate)

	if all && (matched = all) {
		set tSC = ..makeFile(tradeDate)

		set status = 0
		set:'tSC.status status = 2

		do ##class(CFAO.HUBIC.BofficeConf.tables.report).insert(
			"Generate Report CSV",
			tSC.fileName,
			"Report CSV",
			status
		)

		return:'tSC.status 0
	}

	return 1
}

ClassMethod makeFile(tradeDate) As %Status
{
	set file = ##class(%Stream.FileCharacter).%New()
	set fileName = ^boConfRecapFilePath _ "\RE_" _ tradeDate _ "_" _ $replace($zt($p($h, ",", 2)), ":", "") _ ".csv"
	set file.Filename = fileName

	set data = ..getData(tradeDate) return:'data 0
	set mep	= ..mepLines(data)
	set levee = ..leveeLines(data)

	do file.WriteLine("JOURNEE DU " _ $replace(tradeDate, "-", "/"))
	do file.WriteLine("")

	if mep {
		do file.WriteLine("MISE EN PLACE")

		set i = mep.%GetIterator()

		while i.%GetNext(.key, .row) {
			do file.WriteLine(row)
		}

		do file.WriteLine("")
	}

	if levee {
		do file.WriteLine("LEVEE")

		set i = levee.%GetIterator()

		while i.%GetNext(.key, .row) {
			do file.WriteLine(row)
		}
	}

	set tSC = file.%Save()

	set result = {}
	set result.fileName = fileName
	set:tSC result.status = 1
	set:'tSC result.status = 0

	if 'tSC $$$LOGWARNING(tSC)

	return result
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
			AND historized = 0
	)

	return all
}

ClassMethod getData(tradeDate) As %Status
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
		_ " tradeDate = '" _ tradeDate _ "'"
	_ " ORDER BY deviseReceived, bank, tradeType"

	set data = ##class(CFAO.HUBIC.Outils).queryJSON(request)

	return:data.%Size() data
	return 0
}

ClassMethod mepLines(data) As %Status
{
	set i = data.%GetIterator()
	set result = []
	set separator = ";"
	set previous = data.%Get(0).tradeType
	set total = 0

	while i.%GetNext(.key, .val) {

		set row = val
		set tradeType = row.tradeType

		continue:'..isMep(tradeType)

		if previous '= tradeType {
			do result.%Push(
				  row.deviseReceived
				_ separator _ "Total " _ previous
				_ separator
				_ separator
				_ separator
				_ separator
				_ separator
				_ separator
				_ separator _ total
			)

			set total = 0
		}

		do result.%Push(
			  row.deviseReceived
			_ separator _ row.tradeType
			_ separator _ row.bank
			_ separator _ row.amountReceived
			_ separator _ row.spot
			_ separator _ row.term
			_ separator _ row.valueDate
			_ separator _ row.amountPaid
			_ separator _ row.amountReceived
		)

		set total = total + row.amountReceived
		set previous = tradeType
	}

	return:'result.%Size() 0

	do result.%Push(
			row.deviseReceived
		_ separator _ "Total " _ tradeType
		_ separator
		_ separator
		_ separator
		_ separator
		_ separator
		_ separator
		_ separator _ total
	)

	return result
}

ClassMethod leveeLines(data) As %Status
{
	set i = data.%GetIterator()
	set result = []
	set separator = ";"
	set previous = data.%Get(0).tradeType
	set total = 0
	set total2 = 0

	while i.%GetNext(.key, .val) {
		set row = val
		set tradeType = row.tradeType

		continue:'..isLevee(tradeType)

		if previous '= tradeType {
			do result.%Push(
				  row.deviseReceived
				_ separator _ previous
				_ separator _ "Total " _ row.bank
				_ separator
				_ separator
				_ separator
				_ separator
				_ separator
				_ separator _ total
				_ separator _ total2
			)

			set total = 0
		}

		do result.%Push(
			  row.deviseReceived
			_ separator _ row.tradeType
			_ separator _ row.bank
			_ separator _ row.amountReceived
			_ separator _ row.spot
			_ separator _ row.term
			_ separator _ row.valueDate
			_ separator _ row.amountPaid
			_ separator _ row.amountReceived
			_ separator _ row.amountPaid
		)

		set total = total + row.amountReceived
		set total2 = total2 + row.amountPaid
		set previous = tradeType
	}

	return:'result.%Size() 0

	do result.%Push(
		  row.deviseReceived
		_ separator _ tradeType
		_ separator _ "Total " _ row.bank
		_ separator
		_ separator
		_ separator
		_ separator
		_ separator
		_ separator _ total
		_ separator _ total2
	)

	return result
}

ClassMethod isMep(tradeType) As %Status
{
	if (tradeType = "ERAT")
	|| (tradeType = "ERVT")
	|| (tradeType = "SWAAA")
	|| (tradeType = "SWAAF")
	|| (tradeType = "SWAV")
	|| (tradeType = "SWAVF")
	|| (tradeType = "EAAT")
	|| (tradeType = "EVAT")
	{
		return 1
	}

	return 0
}

ClassMethod isLevee(tradeType) As %Status
{
	if (tradeType = "ELVT")
	|| (tradeType = "EVSP")
	|| (tradeType = "ELVTA")
	|| (tradeType = "EVSPA")
	|| (tradeType = "ELAT")
	|| (tradeType = "EASP")
	|| (tradeType = "ELATA")
	|| (tradeType = "EASPA")
	{
		return 1
	}

	return 0
}

}

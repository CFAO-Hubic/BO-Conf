Class CFAO.HUBIC.BofficeConf.BO.forex.validation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method validate(pRequest As CFAO.HUBIC.BofficeConf.tables.forexBatch, Output pResponse As CFAO.HUBIC.BofficeConf.messages.validateForexMsg) As %Status
{
	set key = pRequest.forexRecords.Next()

	set (
		invalid,
		duplicate,
		inTab,
		processed
	 ) = []

	while (key '= "") {
		set status	= pRequest.forexRecords.GetAt(key).APPLICATIVESTATUSNAME
		set idForex	= pRequest.forexRecords.GetAt(key).IDforex
		set idBatch	= pRequest.forexRecords.GetAt(key).%ParentBatch

		if status '= "Validated" do invalid.%Push(key)

		if hasDuplicate(idForex, idBatch) {
			set inArray = ##class(CFAO.HUBIC.Outils).inArray(duplicate, idForex)
			if 'inArray do duplicate.%Push(idForex)
		}

		if isInTab(idForex) {
			set inArray = ##class(CFAO.HUBIC.Outils).inArray(inTab, idForex)
			if 'inArray do inTab.%Push(idForex)
		}

		if isProcessed(idForex) {
			set inArray = ##class(CFAO.HUBIC.Outils).inArray(processed, idForex)
			if 'inArray do processed.%Push(idForex)
		}

		set key = pRequest.forexRecords.Next(key)
	}

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.validateForexMsg).%New()

	set pResponse.invalid	= invalid
	set pResponse.duplicate	= duplicate
	set pResponse.inTab		= inTab
	set pResponse.processed	= processed

	if 'invalid.%Size() && 'duplicate.%Size() && 'inTab.%Size() && 'processed.%Size() {
		set pResponse.status = 1
	} else {
		set pResponse.status = 0
	}
}

ClassMethod hasDuplicate(idForex, idBatch) As %Integer
{
	&sql(
		SELECT count(IDforex)
		INTO :count
		FROM CFAO_HUBIC_BofficeConf_recordMap_JournalForex.Record  
		WHERE
			IDforex 		 = :idForex 
			AND %ParentBatch = :idBatch
	)

	return count - 1
}

ClassMethod isInTab(idForex) As %Integer
{
	&sql(
		SELECT count(idForex)
		INTO :count
		FROM CFAO_HUBIC_BofficeConf_tables.forex
		WHERE
			idForex 	 = :idForex 
			AND archived = 0
	)

	return count - 1
}

ClassMethod isProcessed(idForex) As %Integer
{
	&sql(
		SELECT count(idForex)
		INTO :count
		FROM CFAO_HUBIC_BofficeConf_tables.forex
		WHERE
			idForex 	 = :idForex 
			AND archived = 1
	)

	return count - 1
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.tables.forexBatch"> 
		<Method>validate</Method>
	</MapItem>
</MapItems>
}

}

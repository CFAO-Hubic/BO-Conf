Class CFAO.HUBIC.BofficeConf.BO.forex.insert Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method insert(pRequest As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch, Output pResponse As %String) As %Status
{
	set key = pRequest.Records.Next()
	set (batchId, pResponse) = ..setBatchId()

	while (key '= "") {
		set data = {}

		set data.forexFileName		= pRequest.Records.GetAt(key).%Source
		set data.idBatch			= batchId
		set data.forexStatus		= pRequest.Records.GetAt(key).APPLICATIVESTATUSNAME
		set data.idForex			= pRequest.Records.GetAt(key).IDforex
		set data.bank				= pRequest.Records.GetAt(key).CPTYSHORTNAME
		set data.tradeDate			= pRequest.Records.GetAt(key).TRADEDATE
		set data.valueDate			= pRequest.Records.GetAt(key).VALUEDATE
		set data.maturityDate		= pRequest.Records.GetAt(key).MATURITYDATE
		set data.amount1			= pRequest.Records.GetAt(key).AMOUNT1
		set data.devise1			= pRequest.Records.GetAt(key).CURRENCY1SHORTNAME
		set data.amount1Remaining	= pRequest.Records.GetAt(key).REMAININGAMOUNT1
		set data.amount2			= pRequest.Records.GetAt(key).AMOUNT2
		set data.devise2			= pRequest.Records.GetAt(key).CURRENCY2SHORTNAME
		set data.term				= pRequest.Records.GetAt(key).CLIENTRATE
		set data.spot				= pRequest.Records.GetAt(key).SPOTRATE
		set data.reference			= pRequest.Records.GetAt(key).REFERENCE
		set data.tradeType			= pRequest.Records.GetAt(key).TRADETYPESHORTNAME
		set data.utiCci				= pRequest.Records.GetAt(key).UTICCI
		set data.parentTradeCce		= pRequest.Records.GetAt(key).PARENTTRADECCE

		set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).save(data)

		if 'tSC $$$LOGWARNING("La ligne " _ key + 1 _ " du journal forex " _ pRequest.%Source _ " n'a pas pu être insérée dans la table forex : " _ $c(13,10) _ "Erreur : " _ $c(13,10) _ tSC)

		set key = pRequest.Records.Next(key)
	}

	quit $$$OK
}

ClassMethod setBatchId() As %Status
{
	&sql(
		SELECT MAX(idBatch)
		INTO :idBatch
		FROM CFAO_HUBIC_BofficeConf_tables.forex
	)

	return idBatch + 1
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch"> 
		<Method>insert</Method>
	</MapItem>
</MapItems>
}

}

Class CFAO.HUBIC.BofficeConf.BO.forex.match Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property pathPDF As %String;

Property SMTP As %String;

Property sender As %String;

Parameter SETTINGS = "pathPDF, SMTP, sender";

Method check(pRequest As Ens.Request, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkForexMsg) As %Status
{
	set idBatch = pRequest.StringValue
	$$$LOGINFO("ID Batch : " _ idBatch _ " --------------------------")

	set ^boConfSettings = {}
	set ^boConfSettings.SMTP = ..SMTP
	set ^boConfSettings.pathPDF = ..pathPDF
	set ^boConfSettings.sender = ..sender

	set errorsForex = []
	set errorsBank = []

	set request =
		  "SELECT * "
		_ "FROM CFAO_HUBIC_BofficeConf_tables.forex "
		_ "WHERE idBatch = " _ idBatch

	set data = ##class(CFAO.HUBIC.Outils).queryJSON(request)
	set iter = data.%GetIterator()

	while iter.%GetNext(.key, .row) {

		set idEaiForex		= row.ID
		set idForex			= row.idForex
		set bank			= row.bank
		set confType		= row.confType

		// Spot type
		if (((confType = "LEVEE") || (confType = "LEVEE ANN")) && ((bank = "SG") || (bank = "CA")))
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT")) && ((bank = "CA") || (bank = "SG"))) 
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT") || (confType = "LEVEE")
		|| (confType = "LEVEE ANN") || (confType = "PRORO")) && (bank = "BNP")) {

			set matchedRow = ..match(row, 0)

			if 'matchedRow.match continue

			set matchedRow.idEaiForex = idEaiForex
			set matchedRow.idForex = idForex

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(matchedRow, matchedRow.match)
			if 'tSC do errorsForex.%Push(matchedRow.idForex)

			set tSC2 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(matchedRow)
			if 'tSC2 do errorsBank.%Push(matchedRow.idEaiBank)

			if 'tSC || 'tSC2 continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(matchedRow.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ matchedRow.idEaiForex _ $c(13,10) _ tSC)

		// SWAP type (the line must find 2 conf : spot and term)
		} elseif ((confType = "SWAP") && ((bank = "CA") || (bank = "SG"))) {

			set spot = ..match(row, 0)
			set spot.idEaiForex = idEaiForex
			set spot.idForex = idForex

			set term = ..match(row, 1)
			set term.idEaiForex = idEaiForex
			set term.idForex = idForex

			if ('spot.match && 'term.match) continue
			if (spot.match && 'term.match) set spot.match = 9999
			if ('spot.match && term.match) set term.match = 9999

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(spot, spot.match)
			if 'tSC do errorsForex.%Push(matchedRow.idForex _ "(spot)")

			set tSC2 = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(term, term.match)
			if 'tSC2 do errorsForex.%Push(matchedRow.idForex _ "(term)")

			set tSC3 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(spot)
			if 'tSC3 do errorsBank.%Push(spot.idEaiBank _ "(spot)")

			set tSC4 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(term)
			if 'tSC4 do errorsBank.%Push(term.idEaiBank _ "(term)")

			if 'tSC || 'tSC2 || 'tSC3 || 'tSC4 continue
			if 'spot.match || 'term.match continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(spot.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ spot.idEaiForex _ $c(13,10) _ tSC)

			if spot.confFileName '= term.confFileName {
				set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(term.idEaiBank)
				if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ term.idEaiForex _ $c(13,10) _ tSC)
			} else {
				set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).updateEmailStatus(term.idEaiBank)
			}

		// Term type
		} else {

			set matchedRow = ..match(row, 1)

			if 'matchedRow.match continue

			set matchedRow.idEaiForex = idEaiForex
			set matchedRow.idForex = idForex
			$$$LOGINFO(matchedRow.%ToJSON())

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(matchedRow, matchedRow.match)
			if 'tSC do errorsForex.%Push(matchedRow.idForex)

			set tSC2 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(matchedRow)
			if 'tSC2 do errorsBank.%Push(matchedRow.idEaiBank)

			if 'tSC || 'tSC2 continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(matchedRow.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ matchedRow.idEaiForex _ $c(13,10) _ tSC)
		}
	}

	do ##class(CFAO.HUBIC.BofficeConf.functions.historization).historize()

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkForexMsg).%New()

	if errorsForex.%Size() || errorsBank.%Size() {
		set pResponse.forex = $REPLACE($REPLACE($E(errorsForex.%ToJSON(), 2, *-1), """", ""), ",", ", ")
		set pResponse.bank	= $REPLACE($REPLACE($E(errorsBank.%ToJSON()	, 2, *-1), """", ""), ",", ", ")
		set pResponse.status = 0
	} else {
		set pResponse.status = 1
	}

	Quit $$$OK
}

ClassMethod match(row, type = 0) As %Library.DynamicArray
{
	set bank			= row.bank
	set tradeDate		= row.tradeDate
	set deviseReceived	= row.deviseReceived
	set devisePaid		= row.devisePaid
	set amountReceived	= row.amountReceived
	set amountPaid		= row.amountPaid
	set maturityDate	= row.maturityDate
	set valueDate		= row.valueDate
	set term			= row.term
	set spot			= row.spot

	set request =
		"SELECT"
			_ " COUNT(*) AS ""match"","
			_ " ID AS ""idEaiBank"","
			_ " confFileName,"
			_ " contrat"
		_ " FROM CFAO_HUBIC_BofficeConf_tables.bank"
		_ " WHERE"
			_ " matchStatus 		= 0"
			_ " AND bank			= '" _ bank				_ "'"
			_ " AND tradeDate 		= '" _ tradeDate 		_ "'"
			_ " AND deviseReceived 	= '" _ deviseReceived	_ "'"
			_ " AND devisePaid		= '" _ devisePaid		_ "'"
			_ " AND amountReceived	= '" _ amountReceived	_ "'"
			_ " AND amountPaid		= '" _ amountPaid		_ "'"

	if type = 0 {
		set request = request
			_ " AND valueDate 		= '" _ valueDate 		_ "'"
			_ " AND spot 			= '" _ spot 			_ "'"
	}

	if type = 1 {
		set request = request
			_ " AND maturityDate 	= '" _ maturityDate 	_ "'"
			_ " AND term 		 	= '" _ term				_ "'"
	}

	set data = ##class(CFAO.HUBIC.Outils).queryJSON(request)

	if data.%IsDefined(0) {
		return data.%Get(0)
	} else {
		return {}
	}
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.Request">
		<Method>check</Method>
	</MapItem>
</MapItems>
}

}

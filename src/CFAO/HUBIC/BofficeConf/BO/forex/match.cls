Class CFAO.HUBIC.BofficeConf.BO.forex.match Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property pathPDF As %String;

Property SMTP As %String;

Property sender As %String;

Parameter SETTINGS = "pathPDF, SMTP, sender";

/// Opérations : Enreg Back Order Confirmation Journal Forex
/// 
/// cette classe enregistre les lignes des journaux forex en attente de confirmation de banques
/// elle recherche aussi si une confirmation de banques existe deja 
/// si une confirmation de banques est trouver, la ligne est enregistrer avec un statut rapprocher
/// sinon le ligne est enregistrer avec un statut non rapprocher
/// 
/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
/// This is the default message handler.  All request types not declared in the message map are delivered here
/// Method EnregEtRapprochePJ(pRequest As CFAO.HUBIC.EMIRtools.recordMap.JournalForex.Batch, Output pResponse As Ens.StringResponse) As %Status
Method check(pRequest As CFAO.HUBIC.BofficeConf.tables.forexBatch, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkForexMsg) As %Status
{
	set ^boConfSettings = {}
	set ^boConfSettings.SMTP = ..SMTP
	set ^boConfSettings.pathPDF = ..pathPDF
	//set ^boConfSettings.sender = ..sender

	set errorsForex = []
	set errorsBank = []

	set key = pRequest.forexRecords.Next()

	while(key '= "") {
		set idEaiForex		= pRequest.forexRecords.GetAt(key).%Id()
		set idForex			= pRequest.forexRecords.GetAt(key).idForex
		set bank			= pRequest.forexRecords.GetAt(key).bank
		set confType		= pRequest.forexRecords.GetAt(key).confType

		// Spot type
		if (((confType = "LEVEE") || (confType = "LEVEE ANN")) && ((bank = "SG") || (bank = "CA")))
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT")) && ((bank = "CA") || (bank = "SG"))) 
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT") || (confType = "LEVEE")
		|| (confType = "LEVEE ANN") || (confType = "PRORO")) && (bank = "BNP")) {

			set data = ..match(pRequest, 0)

			if data.match continue

			set data.idEaiForex = idEaiForex
			set data.idForex = idForex

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(data, data.match)
			if 'tSC do errorsForex.%Push(data.idForex)

			set tSC2 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(data)
			if 'tSC2 do errorsBank.%Push(data.idEaiBank)

			if 'tSC || 'tSC2 continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(data.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ data.idEaiForex _ $c(13,10) _ tCS)

		// SWAP type (the line must find 2 conf : spot and term)
		} elseif ((confType = "SWAP") && ((bank = "CA") || (bank = "SG"))) {
			set spot = ..match(pRequest, 0)
			set spot.idEaiForex = idEaiForex
			set spot.idForex = idForex

			set term = ..match(pRequest, 1)
			set term.idEaiForex = idEaiForex
			set term.idForex = idForex

			if (spot.match && 'term.match) set spot.match = 9999
			if ('spot.match && term.match) set term.match = 9999

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(spot, spot.match)
			if 'tSC do errorsForex.%Push(data.idForex _ "(spot)")

			set tSC2 = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(term, term.match)
			if 'tSC2 do errorsForex.%Push(data.idForex _ "(term)")

			set tSC3 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(spot)
			if 'tSC3 do errorsBank.%Push(spot.idEaiBank _ "(spot)")

			set tSC4 = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(term)
			if 'tSC4 do errorsBank.%Push(term.idEaiBank _ "(term)")

			if 'tSC || 'tSC2 || 'tSC3 || 'tSC4 continue
			if 'spot.match || 'term.match continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(spot.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ spot.idEaiForex _ $c(13,10) _ tCS)

			if spot.confFileName '= term.confFileName {
				set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(term.idEaiBank)
				if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ term.idEaiForex _ $c(13,10) _ tCS)
			} else {
				set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).updateEmailStatus(term.idEaiBank)
			}

		// Term type
		} else {
			set data = ..match(pRequest, 1)

			if data.match continue

			set data.idEaiForex = idEaiForex
			set data.idForex = idForex

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(data, data.match)
			if 'tSC do errorsForex.%Push(data.idForex)

			set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.bank).match(data)
			if 'tSC do errorsBank.%Push(data.idEaiBank)

			if 'tSC || 'tSC2 continue

			set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(data.idEaiBank)
			if 'tSC $$$LOGINFO("Erreur lors de l'envoie de l'email (ID : " _ data.idEaiForex _ $c(13,10) _ tCS)
		}

		set key = pRequest.forexRecords.Next(key)
	}

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkForexMsg).%New()

	if errorsForex.%Size() || errorsBank.%Size() {
		set pResponse.forex = errorsForex
		set pResponse.bank = errorsBank
		set pResponse.status = 1
	} else {
		set pResponse.status = 0
	}

	Quit $$$OK
}

ClassMethod match(pRequest As CFAO.HUBIC.BofficeConf.tables.forexBatch, type = 0) As %Library.DynamicArray
{
	set bank			= pRequest.forexRecords.GetAt(key).bank
	set tradeDate		= pRequest.forexRecords.GetAt(key).tradeDate
	set deviseReceived	= pRequest.forexRecords.GetAt(key).deviseReceived
	set devisePaid		= pRequest.forexRecords.GetAt(key).devisePaid
	set amountReceived	= pRequest.forexRecords.GetAt(key).amountReceived
	set amountPaid		= pRequest.forexRecords.GetAt(key).amountPaid
	set maturityDate	= pRequest.forexRecords.GetAt(key).maturityDate
	set valueDate		= pRequest.forexRecords.GetAt(key).valueDate
	set term			= pRequest.forexRecords.GetAt(key).term
	set spot			= pRequest.forexRecords.GetAt(key).spot

	set request =
		"SELECT"
			_ " COUNT(*) AS ""match"","
			_ " ID AS ""idEaiForex"","
			_ " confFileName,"
			_ " contrat"
		_ " FROM CFAO_HUBIC_BofficeConf_tables.forex"
		_ " WHERE"
			_ " matchStatus = 0"
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
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.tables.forexBatch">
		<Method>check</Method>
	</MapItem>
</MapItems>
}

}

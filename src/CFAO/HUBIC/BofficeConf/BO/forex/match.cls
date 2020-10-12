Class CFAO.HUBIC.BofficeConf.BO.forex.match Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

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
Method EnregEtRapproche(pRequest As CFAO.HUBIC.BofficeConf.tables.forexBatch, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkForexMsg) As %Status
{
	set errorsForex = []
	set errorsBank = []

	set matchDate = $ZDATETIME($h, 3)

	set key = pRequest.forexRecords.Next()

	while(key '= "") {
		set idForex			= pRequest.forexRecords.GetAt(key).idForex
		set idEaiForex		= pRequest.forexRecords.GetAt(key).%Id()
		set bank			= pRequest.forexRecords.GetAt(key).bank
		set tradeDate		= pRequest.forexRecords.GetAt(key).tradeDate
		set maturityDate	= pRequest.forexRecords.GetAt(key).maturityDate
		set valueDate		= pRequest.forexRecords.GetAt(key).valueDate
		set deviseReceived	= pRequest.forexRecords.GetAt(key).deviseReceived
		set devisePaid		= pRequest.forexRecords.GetAt(key).devisePaid
		set amountReceived	= pRequest.forexRecords.GetAt(key).amountReceived
		set amountPaid		= pRequest.forexRecords.GetAt(key).amountPaid
		set term			= pRequest.forexRecords.GetAt(key).term
		set spot			= pRequest.forexRecords.GetAt(key).spot
		set confType		= pRequest.forexRecords.GetAt(key).confType

		set (
			match,
			matchSpot,
			matchTerm,
			twoConfNeeded,
			onlyOnePdf
		) = 0

		set (
			confFileName,
			confFileNameSpot,
			confFileNameTerm,
			contrat,
			contratSpot,
			contratTerm
		) = ""

		if (((confType = "LEVEE") || (confType = "LEVEE ANN")) && ((bank = "NAT") || (bank = "SG") || (bank = "CA")))
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT")) && ((bank = "CA") || (bank = "SG"))) 
		|| (((confType = "MEP SPOT ANN") || (confType = "MEP SPOT")) && (bank = "BNP")) {

			if (confType = "MEP SPOT") && (bank = "SG"){
	    		&sql(
		    		SELECT
		    			COUNT(*),
		    			ID,
		    			confFileName,
		    			contrat 
		    		INTO
		    			:match,
		    			:idEaiBank,
		    			:confFileName,
		    			:contrat
		    		FROM CFAO_HUBIC_BofficeConf_tables.bank
			    	WHERE 
				    		valueDate	= :valueDate
				    	AND bank		= :bank
				    	AND deviseReceived	= :deviseReceived
				    	AND amountReceived	= :amountReceived
				    	AND spot		= :spot
				    	AND matchStatus	= 0
				    	AND confType LIKE '%MEP%'
		    	)

			} else {
	    		&sql(
		    		SELECT
		    			COUNT(*),
		    			ID,
		    			confFileName,
		    			contrat 
		    		INTO
		    			:match,
		    			:idEaiBank,
		    			:confFileName,
		    			:contrat
		    		FROM CFAO_HUBIC_BofficeConf_tables.bank
			    	WHERE
				    		valueDate	= :valueDate
				    	AND bank		= :bank
				    	AND deviseReceived	= :deviseReceived
				    	AND amountReceived	= :amountReceived
				    	AND spot		= :spot
				    	AND matchStatus = 0
		    	)
			}

		//Pour les SWAP, la ligne forex doit trouver deux ligne de confirmation, Comptant et Terme
		} elseif ((confType = "SWAP") && ((bank = "CA") || (bank = "SG"))) || ((confType = "PRORO") && (bank = "NAT"))  {

			if (confType = "SWAP") && (bank = "SG"){
				// SPOT
	    		&sql(
		    		SELECT
		    			COUNT(*),
		    			ID,
		    			confFileName,
		    			contrat 
		    		INTO
		    			:matchSpot,
		    			:idEaiBankSpot,
		    			:confFileNameSpot,
		    			:contratSpot
		    		FROM CFAO_HUBIC_BofficeConf_tables.bank
			    	WHERE
				    		valueDate	= :valueDate
				    	AND bank		= :bank
				    	AND deviseReceived	= :deviseReceived
				    	AND amountReceived	= :amountReceived
				    	AND spot		= :spot
				    	AND matchStatus	= 0
				    	AND	confType LIKE '%SWAP%'
		    	)
		    	
		    	// TERME
		    	&sql(
			    	SELECT
			    		COUNT(*),
		    			ID,
			    		confFileName,
			    		contrat 
			    	INTO
			    		:matchTerm,
			    		:idEaiBankTerm,
			    		:confFileNameTerm,
			    		:contratTerm
			    	FROM CFAO_HUBIC_BofficeConf_tables.bank
			    	WHERE 
			    			valueDate	= :maturityDate
				    	AND bank		= :bank
				    	AND deviseReceived	= :deviseReceived
				    	AND amountReceived	= :amountReceived
				    	AND spot		= :term
				    	AND matchStatus	= 0
				    	AND confType LIKE '%SWAP%'
		    	)

			} else {
				// SPOT
	    		&sql(
		    		SELECT
		    			COUNT(*),
		    			ID,
		    			confFileName,
		    			contrat 
		    		INTO
		    			:matchSpot,
		    			:idEaiBankSpot,
		    			:confFileNameSpot,
		    			:contratSpot
		    		FROM CFAO_HUBIC_BofficeConf_tables.bank
			    	WHERE
				    		valueDate	= :valueDate
				    	AND bank		= :bank
				    	AND deviseReceived	= :deviseReceived
				    	AND amountReceived	= :amountReceived
				    	AND spot		= :spot
				    	AND matchStatus	= 0
		    	)

		    	// TERM
		    	&sql(
					SELECT
						COUNT(*),
		    			ID,
						confFileName,
						contrat 
					INTO
						:matchTerm,
						:idEaiBankTerm,
						:confFileNameTerm,
						:contratTerm
					FROM CFAO_HUBIC_BofficeConf_tables.bank
					WHERE
							valueDate	= :maturityDate
						AND bank		= :bank
						AND deviseReceived	= :deviseReceived
						AND amountReceived	= :amountReceived
						AND term		= :term
						AND matchStatus	= 0
		    	)
			}
			
			set separator = ""
	    	if matchSpot && matchTerm set separator = "-"

			set match		= matchSpot + matchTerm
			set confFileName= confFileNameSpot _ separator _ confFileNameTerm
			set contrat		= contratSpot _ separator _ contratTerm

	    	//y a t'il un seule PDF contenant deux confirmation
	    	if confFileNameSpot = confFileNameTerm set onlyOnePdf = 1

	    	set twoConfNeeded = 1

		} elseif ((confType = "LEVEE") || (confType = "LEVEE ANN") || (confType = "PRORO")) && (bank = "BNP") {

	    	&sql(
		    	SELECT
		    		COUNT(*),
		    		ID,
		    		confFileName,
		    		contrat
	    		INTO
	    			:match,
	    			:idEaiBank,
	    			:confFileName,
	    			:contrat
	    		FROM CFAO_HUBIC_BofficeConf_tables.bank
		    	WHERE
			    		valueDate	= :valueDate
			    	AND bank 		= :bank
			    	AND deviseReceived	= :deviseReceived
			    	AND amountReceived	= :amountReceived
			    	AND spot 		= :spot
			    	AND matchStatus = 0
	    	)

		} else {
			//on verifie si une confirmation est deja presente pour les autres types
			&sql(
	    		SELECT
	    			COUNT(*),
		    		ID,
	    			confFileName,
	    			contrat
	    		INTO
	    			:match,
	    			:idEaiBank,
	    			:confFileName,
	    			:contrat
	    		FROM CFAO_HUBIC_BofficeConf_tables.bank
		    	WHERE
		    			valueDate	= :maturityDate
			    	AND bank		= :bank
			    	AND deviseReceived	= :deviseReceived
			    	AND amountReceived	= :amountReceived
			    	AND spot		= :term
			    	AND matchStatus	= 0
	    	)
		}

		if match {

			set line = ##class(CFAO.HUBIC.BofficeConf.tables.forex).%OpenId(idEaiForex)
			set line.confFileName = confFileName
			set line.contrat = contrat
	    	set line.matchDate = matchDate

			if twoConfNeeded {

		    	if matchSpot && matchTerm {
					set line.matchStatus = 1
		    	}

		    	if ('matchSpot && matchTerm) || (matchSpot && 'matchTerm) { // If neither spot conf nor term conf have been found, validation shouldn't be set to "PREMIER"
					set line.matchStatus = 0
					set line.validation = "Premier"
		    	}

			} else {
				set line.matchStatus = 1
				set line.validation = "AUTO"
			}

			set tSC = line.%Save()

			if 'tSC do errorsForex.%Push(idForex)

			if tSC {
				//Mise a jour du raprochement pour la confirmation de banques trouvée
				if twoConfNeeded {
					if matchSpot set idEaiBank = idEaiBankSpot
					if matchTerm set idEaiBank = idEaiBankTerm
					set line =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(idEaiBank)
				} else {
					set line =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(idEaiBank)
					set line.confType = confType
				}

				set line.matchStatus = 1
				set line.idForex = idForex
				set line.idEaiForex = idEaiForex
				set tSC = line.%Save()

				if 'tSC do errorsBank.%Push(idForex)
			}

			// Envoi du mail a la banque **************************************************************************************		
			if tSC {
				if twoConfNeeded set idEaiBank = idEaiBankSpot
				set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(idEaiBank)
				if 'tSC $$$LOGINFO(tSC_" | ID : idEaiForex")
			}
			// ****************************************************************************************************************
		} // if match
		
		set key = pRequest.forexRecords.Next(key)

	} // Fin de while(key '= "")

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkForexMsg).%New()

	if errorsForex.%Size() {
		set pResponse.forex = errorsForex
		set pResponse.bank = errorsBank
		set pResponse.status = 1
	} else {
		set pResponse.status = 0
	}

	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.tables.forexBatch">
		<Method>EnregEtRapproche</Method>
	</MapItem>
</MapItems>
}

}

Class CFAO.HUBIC.BofficeConf.BO.banks.SG.levee Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "LEVEE"

	set i = 0
	set lineBuyed = ""
	set lineSelled = ""
	set idFX = ""

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	// Getting the identifier to find the line with the confirmation data
	while 'pRequest.AtEnd {
		if $Find(line,"La date de levée anticipée pour toutes les Opérations est fixée au") > 0 {
			set date = $piece($piece(line,"au ",2)," (",1)
			set idFx = ##class(CFAO.HUBIC.Outils).convertTextDate(date, "/", 3)
		}
	}

	if idFx = "" {
	    set pResponse.status = 0
	    set pResponse.message = "SGLEVEE - Impossible de trouver l'identifiant FX (identification de la ligne contenant les infos sur la conf)"
	    quit $$$OK
	}

	do pRequest.Rewind()

	while 'pRequest.AtEnd {
		set i = i + 1
		set line = pRequest.ReadLine()


		if $Find(line ,"Paiement à SOCIETE GENERALE") > 0 {
			set lineBuyed = i + 1
		}

		if lineBuyed = i {
			set data.amountBuy =  $piece(line," ",1)
			set data.deviseBuy = $piece(line," ",2)
		}

		if $Find(line ,"Paiement à CFAO") > 0 {
			set lineSelled = i + 1
		}

		If lineSelled = i {
			set data.amountSell =  $piece(line," ",1)
			set data.deviseSell = $piece(line," ",2)
		}

		If $Find(line,idFX) {
			set data.contrat	= $piece(line," ",1)
			set data.opeRef		= $piece(line," ",1)
			set data.spot		= $piece(line," ",7)
			set data.tradeDate	= $piece(line," ",8)
			set data.valueDate	= $piece(line," ",9)
		}
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 2) {
	    set pResponse.status = 0
	    set pResponse.message = "SGSWAP - Valeur de rapprochement terme manquante"
	    quit $$$OK
    }

	set resultMatch = ..match(data)

	if resultMatch.%IsDefined(0) {
		set data.idForex	= resultMatch.%Get(0).idForex
		set data.idEaiForex	= resultMatch.%Get(0).idEaiForex
		set match 			= resultMatch.%Get(0).match
	} else {
		set match = 0
	}

	set resultSave = ..save(data, match)

	set pResponse.status = resultSave.status
	set pResponse.message = resultSave.message

	quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="%Stream.FileCharacter"> 
		<Method>saveAndCheckMatch</Method>
	</MapItem>
</MapItems>
}

}

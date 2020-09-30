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
			Set date = $piece($piece(line,"au ",2)," (",1)
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
			Set lineBuyed = i + 1
		}

		if lineBuyed = i {
			set data.amountBuy =  $piece(line," ",1)
			set data.deviseBuy = $piece(line," ",2)
		}

		if $Find(line ,"Paiement à CFAO") > 0 {
			set lineSelled = i + 1
		}

		If lineSelled = i {
			Set data.amountSell =  $piece(line," ",1)
			Set data.deviseSell = $piece(line," ",2)
		}

		If $Find(LaLigne,IdentifiantFX) && $Find(LaLigne,LeMontant) {
			Set data.contrat	= $piece(LaLigne," ",1)
			Set data.opeRef		= $piece(LaLigne," ",1)
			Set data.spot		= $piece(LaLigne," ",7)
			Set data.tradeDate	= $piece(LaLigne," ",8)
			Set data.valueDate	= $piece(LaLigne," ",9)
		}
	}

    // Check if every requiered fields are provided
    If 'data.valueDate || 'data.amountBuy || 'data.deviseBuy || 'data.amountSell || 'data.deviseSell || 'data.spot {
	    set pResponse.status = 0
	    set pResponse.message = "SGLEVEE - Valeur de rapprochement manquante"
	    quit $$$OK
    }

	set resultMatch = ..match(data)

	set data.idForex	= resultMatch.idForex
	set data.idEaiForex	= resultMatch.idEaiForex
	set match 			= resultMatch.match

	set pResponse = ..save(data, match)

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

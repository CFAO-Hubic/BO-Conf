Class CFAO.HUBIC.BofficeConf.BO.banks.SG.mepSpot Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "MEP Spot"
	set firstLine = 1

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set line = pRequest.ReadLine()

		// Processed confFileName
		If firstLine = 1 {
			set data.confFileName = line
			set firstLine = 0
		}

		// Contract number
		if $Find(line,"Ref SG de Transaction") {
		   set data.contrat= $replace($piece(line,":",2)," ","")
		}

		// Operation reference
		if $Find(line ,"Ref SG de Transaction") {
			set data.opeRef = $replace($piece(line,":",2)," ","")		   		
		}

		// Trade date (03-MAR-2014)
		if $Find(line ,"Date de Conclusion") {
			set data.tradeDate = ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2), "-")
		}

		// Value date
		if $Find(line ,"Date de Paiement") {
			set data.valueDate = ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2), "-")
		}

		// Spot
		if $Find(line ,"Taux") {
			set data.spot = $replace($piece(line,":",2)," ","") * 1
			if $Extract(data.spot,1,1)="." set data.spot = "0" _ data.spot
		}

		// Buyed
		if $Find(line ,"Montant et Devise à verser par la Partie B") {
			set buyed = $replace($piece(line,":",2)," ","")
			if buyed {
				set data.amountBuy = $extract(buyed,1,*-3)
				set data.deviseBuy = $extract(buyed,*-2,*)
			}
		}

		// Selled
		if $Find(line ,"Montant et Devise à verser par la Partie A") > 0 {
			set selled = $replace($piece(line,":",2)," ","")
			if selled {
				set data.amountSell =  $extract(selled,1,*-3)
				set data.deviseSell = $extract(selled,*-2,*)
			}
		}
	}

    // Check if every requiered fields are provided
    If 'data.valueDate || 'data.amountBuy || 'data.deviseBuy || 'data.amountSell || 'data.deviseSell || 'data.spot {
	    set pResponse.status = 0
	    set pResponse.message = "SGMEP - Valeur de rapprochement manquante"
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

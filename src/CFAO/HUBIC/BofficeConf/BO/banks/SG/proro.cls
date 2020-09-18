Class CFAO.HUBIC.BofficeConf.BO.banks.SG.proro Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "MEP Spot"

	set i = 0
	set lineBuyed = ""
	set lineSelled = ""
	set idFX = 5

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set i = i + 1
		set line = pRequest.ReadLine()

		If i = 1 {
			set data.confFileName = line
		}

		If i = 2 {
			if $Find(LaLigne,"VALIDATED") > 0 set idFx = 6
		}

		If i = idFx {
			set idFx = $replace($piece(line,"/",1)," ","")
			set data.contrat = idFx
		}

		// Data into table
		if $Find(line,idFx) && '$Find(line,"Page") {
			set data.opeRef = idFx
			set data.dates = $Extract(line, *-30,*)
			set data.tradeDate = $replace($piece(dates," ",3)," ","")					
			set data.valueDate = $replace($piece(dates," ",4)," ","")
			set data.spot = $replace($piece(dates," ",2)," ","") * 1
			if $Extract(data.spot,1,1)="."{
				set data.spot = "0" _ data.spot
			}
		}

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

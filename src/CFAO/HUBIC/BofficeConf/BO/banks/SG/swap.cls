Class CFAO.HUBIC.BofficeConf.BO.banks.SG.swap Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	set dataTerm = {}
	set dataSpot = {}
	set (dataTerm.bank, dataSpot.bank) = "SG"
	set (dataTerm.confType, dataSpot.confType) = "MEP Spot"

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

		if $Find(line,"Ref SG de Transaction") {
			set data.contrat = $replace($piece(line,":",2)," ","")
			set data.opeRef = $replace($piece(line,":",2)," ","")
		}

		if $Find(line, "Date de Conclusion") {
			Set dataTerm.tradeDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
			Set dataSpot.tradeDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
		}

		// Spot
		if line = "Patte court terme du swap" {	
			Set lineSpotBuy = i + 2
			Set lineSpotSelled  = i + 1
			Set lineSpotRate  = i + 3
			Set lineSpotValueDate   = i + 4		   		
		}

		if i = lineSpotBuy {
			Set buyed = $replace($piece(line,":",2)," ","")
			Set dataSpot.amountBuy = $extract(buyed,1,*-3)
			Set dataSpot.deviseBuy = $extract(buyed,*-2,*)
		}

		if i = lineSpotSelled {
			Set selled = $replace($piece(line,":",2)," ","")
			Set dataSpot.amountSell = $extract(NousVendonsC,1,*-3)
			Set dataSpot.deviseSell = $extract(NousVendonsC,*-2,*)
		}

		if i = lineSpotRate {
			Set dataSpot.spot = $replace($piece(line,":",2)," ","") * 1
			if $Extract(dataSpot.spot,1,1)="."{
				set dataSpot.spot = "0" _ dataSpot.spot
			}
		}

		if i = lineSpotValueDate {
			Set dataSpot.valueDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
		}

		// Term
		if $Find(line, dataSpot.contrat) {
			Set lineTermeBuy = i + 2
			Set lineTermSelled  = i + 1
			Set lineTermRate  = i + 3
			Set lineTermValueDate   = i + 4
		}

		if i = lineTermeBuy {
			Set buyed = $replace($piece(line,":",2)," ","")
			Set dataTerm.amountBuy = $extract(buyed,1,*-3)
			Set dataTerm.deviseBuy = $extract(buyed,*-2,*)
		}

		if i = lineTermSelled {
			Set selled = $replace($piece(line,":",2)," ","")
			Set dataTerm.amountSell = $extract(NousVendonsC,1,*-3)
			Set dataTerm.deviseSell = $extract(NousVendonsC,*-2,*)
		}

		if i = lineTermRate {
			Set dataTerm.spot = $replace($piece(line,":",2)," ","") * 1
			if $Extract(dataTerm.spot,1,1)="."{
				set dataTerm.spot = "0" _ dataTerm.spot
			}
		}

		if i = lineTermMaturityDate {
			Set dataTerm.maturityDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
		}
	}

    // Check if every requiered fields are provided
    If 'dataTerm.valueDate || 'dataTerm.amountBuy || 'dataTerm.deviseBuy || 'dataTerm.amountSell || 'dataTerm.deviseSell || 'dataTerm.spot {
	    set pResponse.status = 0
	    set pResponse.message = "SGLEVEE - Valeur de rapprochement terme manquante"
	    quit $$$OK
    }

    If 'dataSpot.valueDate || 'dataSpot.amountBuy || 'dataSpot.deviseBuy || 'dataSpot.amountSell || 'dataSpot.deviseSell || 'dataSpot.spot {
	    set pResponse.status = 0
	    set pResponse.message = "SGLEVEE - Valeur de rapprochement spot manquante"
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

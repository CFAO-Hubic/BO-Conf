Class CFAO.HUBIC.BofficeConf.BO.banks.SG.mepTerm Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

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

		// Processed fileName
		If firstLine = 1 {
			set data.fileName = $p(line, ".", 1)
			set firstLine = 0
		}

		// Contract number
		if $Find(line,"Ref SG de Transaction") {
		   set data.contrat= $replace($piece(line,":",2)," ","")
		}

		// Operation reference
		if $Find(line ,"Ref SG de Transaction") {
			set data.refOpe = $replace($piece(line,":",2)," ","")		   		
		}

		// Trade date (03-MAR-2014)
		if $Find(line ,"Date de Conclusion") {
			set data.tradeDate = ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2), "-")
		}

		// Maturity date
		if $Find(line ,"Date de Paiement") {
			set data.maturityDate = ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2), "-")
		}

		// Term
		if $Find(line ,"Taux") {
			set data.term = $replace($piece(line,":",2)," ","") * 1
			if $Extract(data.term,1,1)="."{
				set data.term = "0" _ data.term
			}
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
    If 'data.amountBuy || 'data.deviseBuy || 'data.amountSell || 'data.deviseSell || 'data.term {
	    set pResponse.status = 0
	    set pResponse.message = "SGMEP - Valeur de rapprochement manquante"
	    quit $$$OK
    }

    // Matching requests between forex and bank tables
	


	&sql(
		SELECT
			COUNT(*),
			idForex,
			ID,
			confType
		INTO
			:match,
			:data.idForex,
			:data.idEaiForex,
			:data.confType
	    FROM CFAO_HUBIC_BofficeConf_tables.forex
		WHERE
		    	maturityDate= :maturityDate
		    AND bank		= :bank
		    AND deviseBuy	= :deviseBuy
		    AND amountBuy	= :amountBuy
		    AND term		= :term
		    AND sens		= :sens
		    AND matchStatus	= 0
	)

	if match = 0 {
    	&sql(
    		SELECT 
	    		COUNT(*),
	    		idForex,
	    		ID,
	    		confType
    		INTO
    			:match,
    			:data.idForex,
    			:data.idEaiForex,
    			:data.confType
	    	FROM CFAO_HUBIC_BofficeConf_tables.forex
		    WHERE
			    	tradeDate	= :tradeDate
			    AND valueDate	= :valueDate
			    AND bank		= :bank
			    AND deviseBuy	= :deviseBuy
			    AND amountBuy	= :amountBuy
			    AND term		= :term
			    AND sens		= :sens
			    AND matchStatus	= 0
			    AND confType like '%MEP%'
	    )
	}

    If match = 0 set confType = "MEP"

	// Insert data into bank table
	set data = {}
	set data.fileName		= fileName
	set data.contrat		= contrat
	set data.tradeDate		= tradeDate
	set data.maturityDate	= maturityDate
	set data.term			= term
	set data.amountBuy		= amountBuy
	set data.amountSell		= amountSell
	set data.deviseBuy		= deviseBuy
	set data.deviseSell		= deviseSell
	set data.bank			= bank
	set data.confType		= confType
	set data.idForex		= idForex
	set data.idEaiForex		= idEaiForex

	set tSC = ..save(data, match)

	set pResponse.status = tSC.status
	set pResponse.message = tSC.message

	Quit $$$OK
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

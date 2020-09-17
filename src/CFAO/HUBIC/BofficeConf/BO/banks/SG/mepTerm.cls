Class CFAO.HUBIC.BofficeConf.BO.banks.SG.mepTerm Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = "SG"

	set bank		= "SG"
	set confType	= "MEP Terme"
	set i = 0

    set match = 0

	set (
		fileName,
		contrat,
		RefOpe,
		tradeDate,
		valueDate,
		maturityDate,
		term,
		sens,
		amountBuy,
		deviseBuy,
		amountSell,
		deviseSell,
		IDForex,
    	IdEAI
	) = ""

	Do pRequest.Rewind()

	While 'pRequest.AtEnd {
		set i = i + 1
		set line = pRequest.ReadLine()

		//Nom du fichier traité -------------------------------------
		If i = 1 {
			set fileName = $p(line, ".", 1)
			$$$LOGINFO("Passage MEP TERME : " _fileName)
		}

		//Numero du contrat -----------------------------------------
		if $Find(line,"Ref SG de Transaction") {
		   set contrat= $replace($piece(line,":",2)," ","")
		}

		//Réference de l'opération ----------------------------------
		if $Find(line ,"Ref SG de Transaction") {
			set RefOpe = $replace($piece(line,":",2)," ","")		   		
		}

		//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 ------
		if $Find(line ,"Date de Conclusion") {
			set tradeDate = $piece(line,": ",2)		   		
		}

		//Date de maturité --------------------------------------------
		if $Find(line ,"Date de Paiement") {
			set maturityDate = $piece(line,": ",2)
		}

		//Terme -----------------------------------
		if $Find(line ,"Taux") {
			set term = $replace($piece(line,":",2)," ","")
			set term = (term * 1)	
			if $Extract(term,1,1)="."{
				set term = "0"_term
			}
		}

		//NOUS ACHETONS --------------------------------------
		if $Find(line ,"Montant et Devise à verser par la Partie B") {
			set buyed = $replace($piece(line,":",2)," ","")
			if buyed {
				set amountBuy = $extract(buyed,1,*-3)
				set deviseBuy = $extract(buyed,*-2,*)
			}
		}

		//NOUS VENDONS ----------------------------------------------
		if $Find(line ,"Montant et Devise à verser par la Partie A") > 0 {
			set selled = $replace($piece(line,":",2)," ","")
			if selled {
				set amountSell =  $extract(selled,1,*-3)
				set deviseSell = $extract(selled,*-2,*)
			}
		}
	}

	//Convert format : 01-JAN-2000 <==> 2000-01-01
	if tradeDate set tradeDate = ##class(CFAO.HUBIC.Outils).convertTextDate(tradeDate)
	if valueDate set valueDate = ##class(CFAO.HUBIC.Outils).convertTextDate(valueDate)
	if maturityDate set maturityDate = ##class(CFAO.HUBIC.Outils).convertTextDate(maturityDate)

    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If 'valueDate || 'amountBuy || 'deviseBuy || 'amountSell || 'deviseSell || 'term {
	    set pResponse.status = 0
	    set pResponse.message = "SGMEP - Valeur de rapprochement manquante"
	    quit $$$OK
    }

    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex
	&sql(
		SELECT
			COUNT(*),
			IDForex,
			ID,
			confType
		INTO
			:match,
			:IDForex,
			:IdEaiForex,
			:confType
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
	    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex
    	&sql(
    		SELECT 
	    		COUNT(*),
	    		IdForex,
	    		ID,
	    		confType
    		INTO
    			:match,
    			:IdForex,
    			:IdEaiForex,
    			:confType
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

	// insert des données dans la tables des confirmations bancaires
	set data = {}
	set data.fileName		= fileName
	set data.contrat		= contrat
	set data.tradeDate		= tradeDate
	set data.valueDate		= valueDate
	set data.maturityDate	= maturityDate
	set data.spot			= spot
	set data.term			= term
	set data.amountBuy		= amountBuy
	set data.amountSell		= amountSell
	set data.deviseBuy		= deviseBuy
	set data.deviseSell		= deviseSell
	set data.bank			= bank
	set data.confType		= confType
	set data.idForex		= idForex
	set data.idEaiForex		= idEaiForex

	set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.bank).save(data, match)

	If 'tSC {
		set pResponse.status = 0
    	set pResponse.message = "Erreur lors de l'enregistrement de la confirmation : "_fileName
	}else{
		set idEaiBank = tSC
	}

	if match {
		set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(idEaiForex, match, fileName, contrat)
		
		if 'tSC {
			 set pResponse.status = 0
			 set pResponse.message = "Erreur lors de la mise à jour de la ligne forex : "_idEaiForex
			 quit $$$OK
		}

		set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(idEaiBank)

		if 'tSC {
			 set pResponse.status = 0
			 set pResponse.message = tSC
			 quit $$$OK
		}
	}

	set pResponse.status = 1
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

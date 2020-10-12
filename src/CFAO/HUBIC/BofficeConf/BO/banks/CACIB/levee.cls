Class CFAO.HUBIC.BofficeConf.BO.banks.CACIB.levee Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "CA"
	set data.confType = "LEVEE"
	set firstLine = 1
	set lineInfo = 1

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to f the relevant informations
	while 'pRequest.AtEnd {
		set line = pRequest.ReadLine()

		// Processed confFileName
		If firstLine = 1 {
			set data.confFileName = line
			set firstLine = 0
		}

        // Maturity date
        if $f(line, "Date d'échéance") {
            set data.maturityDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line,": ",2), "-", 3)
        }

        // Spot
        if $f(line, "Cours au comptant") {
            set data.spot = $replace($p(line,":",2)," ","") * 1
            if $e(data.spot,1,1)="." set data.spot = "0" _ data.spot
        }

        // Term
        if $f(line, "Cours à terme") {
            set data.term = $replace($p(line,":",2)," ","") * 1
            if $e(data.term,1,1)="." set data.term = "0" _ data.term
        }

        // Value date
        if $f(line, "Date de valeur") {
            set data.valueDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line,": ",2), "-", 3)
        }

        // Trade date (03-MAR-2014)
        if $f(line, "Date d'opération") {
            set data.tradeDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line,": ",2), "-", 3)
        }

        if $f(line ,"Instructions de règlement 1 et 2:") set lineInfo = 0

        if lineInfo {
            // Contract number and reference
            if $f(line, "Notre référence") {
                set data.contrat = $p($replace($p(line,":",2)," ",""), "/", 1)
                set data.reference = data.contrat
            }

            // Received
            if $f(line, "Nous vendons") {
                set received = $p(line,": ",2)
                if received '= "" {
                    set data.amountReceived = ..normalize($p(received, " ", 2))
                    set data.deviseReceived = $p(received, " ", 1)
                }
            }

            // Paid
            if $f(line, "Nous achetons") {
                set paid = $p(line,": ",2)
                if paid '= "" {
                    set data.amountPaid = ..normalize($p(paid, " ", 2))
                    set data.devisePaid = $p(paid, " ", 1)
                }
            }
        }
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 2) {
	    set pResponse.status = 0
	    set pResponse.message = data.bank _ " " _ data.confType _ " - Valeur de rapprochement manquante"
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

	set tSC = ..save(data, match)

	set pResponse.status = tSC.status
	set pResponse.message = tSC.message

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

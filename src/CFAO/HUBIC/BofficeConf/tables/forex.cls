Class CFAO.HUBIC.BofficeConf.tables.forex Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property idBatch As %String;

Property idForex As %String;

// IDforex

Property forexFileName As %String(MAXLEN = 2000);

Property confFileName As %String(MAXLEN = 300);

Property utiCci As %String(MAXLEN = 500);

// UTICCI

Property valueDate As %String(MAXLEN = 10);

// VALUEDATE

Property tradeDate As %String(MAXLEN = 10);

// TRADEDATE

Property maturityDate As %String(MAXLEN = 10);

// MATURITYDATE

Property term As %String;

// CLIENTRATE

Property spot As %String;

// SPOTRATE

Property amountReceived As %String;

// AMOUNT1

Property amountReceivedRemaining As %String;

// REMAININGAMOUNT1

Property deviseReceived As %String(MAXLEN = 5);

// CURRENCY1SHORTNAME

Property amountPaid As %String;

// AMOUNT2

Property devisePaid As %String;

// CURRENCY2SHORTNAME

Property sens As %String(MAXLEN = 1);

Property bank As %String(MAXLEN = 5);

// CPTYSHORTNAME

Property tradeType As %String(MAXLEN = 5);

// TRADETYPESHORTNAME

Property matchStatus As %String(MAXLEN = 10);

Property matchDate As %String;

Property confType As %String(MAXLEN = 50);

Property historized As %Integer(DISPLAYLIST = ",Non,Oui", VALUELIST = ",0,1");

Property historizedDate As %String;

Property forexStatus As %String;

// APPLICATIVESTATUSNAME

Property reference As %String;

// REFERENCE

Property parentTradeCce As %String;

// PARENTTRADECCE

Property UTIbanques As %String(MAXLEN = 100);

Property validation As %String(MAXLEN = 20);

Property emailStatus As %Integer(DISPLAYLIST = ",Envoyé, Erreur lors de l'envoi, Pas de destinataire", VALUELIST = ",0,1,2");

Property emailDate As %String;

Property contrat As %String;

ClassMethod save(data As %Library.DynamicArray, match As %Integer) As %Status
{
	set newLine 						= ..%New()

	set newLine.forexFileName			= data.forexFileName
	set newLine.idBatch					= data.idBatch
	set newLine.forexStatus				= data.forexStatus
	set newLine.idForex					= data.idForex
	set newLine.bank					= data.bank
	set newLine.tradeType				= data.tradeType
	set newLine.tradeDate				= data.tradeDate
	set newLine.valueDate				= data.valueDate
	set newLine.maturityDate			= data.maturityDate
	set newLine.amountReceivedRemaining	= data.amount1Remaining
	set newLine.term					= data.term
	set newLine.spot					= data.spot
	set newLine.reference				= data.reference
	set newLine.utiCci					= data.utiCci
	set newLine.parentTradeCce			= data.parentTradeCce
	set newLine.matchStatus				= 0
	set newLine.historized				= 0
	set amount1 = $replace($p($replace(data.amount1, " ", ""), ".", 1), ",", "")
	set amount2 = $replace($p($replace(data.amount2, " ", ""), ".", 1), ",", "")

	if newLine.tradeType = "EVAT" {
		set newLine.confType				= "MEP TERME"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "EAAT" {
		set newLine.confType				= "MEP TERME"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "EVSP" {
		set newLine.confType				= "MEP SPOT"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "EVSPA" {
		set newLine.confType				= "MEP SPOT ANN"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "EASP" {
		set newLine.confType				= "MEP SPOT"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "EASPA" {
		set newLine.confType				= "MEP SPOT ANN"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "ERVT" {
		set newLine.confType				= "PRORO"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "ERAT" {
		set newLine.confType				= "PRORO"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "ELAT" {
		set newLine.confType				= "LEVEE"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "ELATA" {
		set newLine.confType				= "LEVEE ANN"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "ELVT" {
		set newLine.confType				= "LEVEE"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "ELVTA" {
		set newLine.confType				= "LEVEE ANN"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	if newLine.tradeType = "SWAAF" {
		set newLine.confType				= "SWAP"
		set newLine.amountReceived			= amount1
		set newLine.deviseReceived			= data.devise1
		set newLine.amountPaid				= amount2
		set newLine.devisePaid				= data.devise2
	}

	if newLine.tradeType = "SWAVF" {
		set newLine.confType				= "SWAP"
		set newLine.amountReceived			= amount2
		set newLine.deviseReceived			= data.devise2
		set newLine.amountPaid				= amount1
		set newLine.devisePaid				= data.devise1
	}

	quit newLine.%Save()
}

ClassMethod match(data As %Library.DynamicArray, match As %Integer) As %Status
{
	if data.idEaiForex = "" quit "The Id in the data provided is null"
	if 'match quit 1

	set line = ..%OpenId(data.idEaiForex)
	set line.matchStatus = 1
	set line.matchDate = $ZDATETIME($h, 3)
	set line.validation = "AUTO"
	if match = 9999 set line.validation = "Premier" // Cas particulier pour les PRORO SPOT et TERME

	if line.confFileName '= data.confFileName {
		set separator = ""
		if line.confFileName set separator = " | "
		set line.confFileName = line.confFileName _ separator _ $Replace($Piece(data.confFileName,".",1) _ ".pdf"," ","_")
	}

	if line.contrat '= data.contrat {
		set separator = ""
		if line.contrat set separator = " | "
		set line.contrat = line.contrat _ separator _ data.contrat
	}
	
	set tSC = line.%Save()

	quit tSC
}

Storage Default
{
<Data name="forexDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>idBatch</Value>
</Value>
<Value name="3">
<Value>idForex</Value>
</Value>
<Value name="4">
<Value>forexFileName</Value>
</Value>
<Value name="5">
<Value>confFileName</Value>
</Value>
<Value name="6">
<Value>utiCci</Value>
</Value>
<Value name="7">
<Value>valueDate</Value>
</Value>
<Value name="8">
<Value>tradeDate</Value>
</Value>
<Value name="9">
<Value>maturityDate</Value>
</Value>
<Value name="10">
<Value>term</Value>
</Value>
<Value name="11">
<Value>spot</Value>
</Value>
<Value name="12">
<Value>amountReceived</Value>
</Value>
<Value name="13">
<Value>amountReceivedRemaining</Value>
</Value>
<Value name="14">
<Value>deviseReceived</Value>
</Value>
<Value name="15">
<Value>amountPaid</Value>
</Value>
<Value name="16">
<Value>devisePaid</Value>
</Value>
<Value name="17">
<Value>sens</Value>
</Value>
<Value name="18">
<Value>bank</Value>
</Value>
<Value name="19">
<Value>tradeType</Value>
</Value>
<Value name="20">
<Value>matchStatus</Value>
</Value>
<Value name="21">
<Value>matchDate</Value>
</Value>
<Value name="22">
<Value>confType</Value>
</Value>
<Value name="23">
<Value>historized</Value>
</Value>
<Value name="24">
<Value>historizedDate</Value>
</Value>
<Value name="25">
<Value>forexStatus</Value>
</Value>
<Value name="26">
<Value>reference</Value>
</Value>
<Value name="27">
<Value>parentTradeCce</Value>
</Value>
<Value name="28">
<Value>UTIbanques</Value>
</Value>
<Value name="29">
<Value>validation</Value>
</Value>
<Value name="30">
<Value>emailStatus</Value>
</Value>
<Value name="31">
<Value>emailDate</Value>
</Value>
<Value name="32">
<Value>contrat</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeCoAB75.forexD</DataLocation>
<DefaultData>forexDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofficeCoAB75.forexD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeCoAB75.forexI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeCoAB75.forexS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

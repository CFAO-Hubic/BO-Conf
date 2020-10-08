Class CFAO.HUBIC.BofficeConf.tables.forex Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property idForex As %String [ SqlColumnNumber = 2 ];

// IDforex

Property forexFileName As %String(MAXLEN = 2000) [ SqlColumnNumber = 3 ];

Property confFileName As %String(MAXLEN = 300) [ SqlColumnNumber = 4 ];

Property utiCci As %String(MAXLEN = 500) [ SqlColumnNumber = 5 ];

// UTICCI

Property valueDate As %String(MAXLEN = 10) [ SqlColumnNumber = 6 ];

// VALUEDATE

Property tradeDate As %String(MAXLEN = 10) [ SqlColumnNumber = 7 ];

// TRADEDATE

Property maturityDate As %String(MAXLEN = 10) [ SqlColumnNumber = 8 ];

// MATURITYDATE

Property term As %String [ SqlColumnNumber = 9 ];

// CLIENTRATE

Property spot As %String [ SqlColumnNumber = 10 ];

// SPOTRATE

Property amountReceived As %String [ SqlColumnNumber = 11 ];

// AMOUNT1

Property amountReceivedRemaining As %String [ SqlColumnNumber = 12 ];

// REMAININGAMOUNT1

Property deviseReceived As %String(MAXLEN = 5) [ SqlColumnNumber = 13 ];

// CURRENCY1SHORTNAME

Property amountPaid As %String [ SqlColumnNumber = 14 ];

// AMOUNT2

Property devisePaid As %String [ SqlColumnNumber = 15 ];

Property sens As %String(MAXLEN = 1) [ SqlColumnNumber = 16 ];

Property bank As %String(MAXLEN = 5) [ SqlColumnNumber = 17 ];

// CPTYSHORTNAME

Property tradeType As %String(MAXLEN = 5) [ SqlColumnNumber = 18 ];

// TRADETYPESHORTNAME

Property matchStatus As %String(MAXLEN = 10) [ SqlColumnNumber = 19 ];

Property matchDate As %String [ SqlColumnNumber = 20 ];

Property confType As %String(MAXLEN = 50) [ SqlColumnNumber = 21 ];

Property archived As %Integer(DISPLAYLIST = ",Non,Oui", VALUELIST = ",0,1") [ SqlColumnNumber = 22 ];

Property archiveDate As %String [ SqlColumnNumber = 23 ];

Property forexStatus As %String [ SqlColumnNumber = 24 ];

// APPLICATIVESTATUSNAME

Property reference As %String [ SqlColumnNumber = 25 ];

// REFERENCE

Property parentTradeCce As %String [ SqlColumnNumber = 26 ];

// PARENTTRADECCE

Property UTIbanques As %String(MAXLEN = 100) [ SqlColumnNumber = 27 ];

Property validation As %String(MAXLEN = 20) [ SqlColumnNumber = 28 ];

Property emailStatus As %Integer(DISPLAYLIST = ",Envoyé, Erreur lors de l'envoi, Pas de destinataire", VALUELIST = ",0,1,2") [ SqlColumnNumber = 29 ];

Property emailDate As %String [ SqlColumnNumber = 30 ];

Property contrat As %String [ SqlColumnNumber = 31 ];

ClassMethod match(data As %Library.DynamicArray, match As %Integer) As %Status
{
	if data.idEaiForex = "" quit 0

	if match {
		set line = ..%OpenId(data.idEaiForex)
		set line.matchStatus = 1
		set line.validation = "AUTO"
		set line.matchDate = $ZDATETIME($h, 3)

		set separator = ""
		if line.confFileName set separator = " | "
		set line.confFileName = line.confFileName _ separator _ $Replace($Piece(data.confFileName,".",1) _ ".pdf"," ","_")

		set separator = ""
		if line.contrat set separator = " | "
		set line.contrat = line.contrat _ separator _ data.contrat
	}

	if match = 9999 set line.validation = "Premier" // Cas particulier pour les PRORO SPOT et TERME

	set tSC = line.%Save()

	if 'tSC quit 0
	
	quit 1
}

Storage Default
{
<Data name="forexDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>idForex</Value>
</Value>
<Value name="3">
<Value>forexFileName</Value>
</Value>
<Value name="4">
<Value>confFileName</Value>
</Value>
<Value name="5">
<Value>utiCci</Value>
</Value>
<Value name="6">
<Value>valueDate</Value>
</Value>
<Value name="7">
<Value>tradeDate</Value>
</Value>
<Value name="8">
<Value>maturityDate</Value>
</Value>
<Value name="9">
<Value>term</Value>
</Value>
<Value name="10">
<Value>spot</Value>
</Value>
<Value name="11">
<Value>amountReceived</Value>
</Value>
<Value name="12">
<Value>amountReceivedRemaining</Value>
</Value>
<Value name="13">
<Value>deviseReceived</Value>
</Value>
<Value name="14">
<Value>amountPaid</Value>
</Value>
<Value name="15">
<Value>devisePaid</Value>
</Value>
<Value name="16">
<Value>sens</Value>
</Value>
<Value name="17">
<Value>bank</Value>
</Value>
<Value name="18">
<Value>tradeType</Value>
</Value>
<Value name="19">
<Value>matchStatus</Value>
</Value>
<Value name="20">
<Value>matchDate</Value>
</Value>
<Value name="21">
<Value>confType</Value>
</Value>
<Value name="22">
<Value>archived</Value>
</Value>
<Value name="23">
<Value>archiveDate</Value>
</Value>
<Value name="24">
<Value>forexStatus</Value>
</Value>
<Value name="25">
<Value>reference</Value>
</Value>
<Value name="26">
<Value>parentTradeCce</Value>
</Value>
<Value name="27">
<Value>UTIbanques</Value>
</Value>
<Value name="28">
<Value>validation</Value>
</Value>
<Value name="29">
<Value>emailStatus</Value>
</Value>
<Value name="30">
<Value>emailDate</Value>
</Value>
<Value name="31">
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

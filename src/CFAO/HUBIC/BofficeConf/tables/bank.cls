Class CFAO.HUBIC.BofficeConf.tables.bank Extends %Persistent
{

Property idForex As %String(MAXLEN = 50) [ SqlColumnNumber = 2 ];

Property idEaiForex As %String(MAXLEN = 50) [ SqlColumnNumber = 3 ];

Property confFileName As %String(MAXLEN = 2000) [ SqlColumnNumber = 4 ];

Property contrat As %String [ SqlColumnNumber = 5 ];

Property UsiUti As %String(MAXLEN = 50) [ SqlColumnNumber = 6 ];

Property tradeDate As %String(MAXLEN = 10) [ SqlColumnNumber = 7 ];

Property valueDate As %String(MAXLEN = 10) [ SqlColumnNumber = 8 ];

Property maturityDate As %String(MAXLEN = 10) [ SqlColumnNumber = 9 ];

Property term As %String(MAXLEN = 50) [ SqlColumnNumber = 10 ];

Property spot As %String(MAXLEN = 50) [ SqlColumnNumber = 11 ];

Property amountReceived As %String(MAXLEN = 50) [ SqlColumnNumber = 12 ];

Property amountPaid As %String(MAXLEN = 50) [ SqlColumnNumber = 13 ];

Property deviseReceived As %String(MAXLEN = 50) [ SqlColumnNumber = 14 ];

Property devisePaid As %String(MAXLEN = 50) [ SqlColumnNumber = 15 ];

Property sens As %String(MAXLEN = 50) [ SqlColumnNumber = 16 ];

Property bank As %String(MAXLEN = 20) [ SqlColumnNumber = 17 ];

Property confType As %String(MAXLEN = 20) [ SqlColumnNumber = 18 ];

Property matchStatus As %String(MAXLEN = 10) [ SqlColumnNumber = 19 ];

Property matchDate As %String(MAXLEN = 20) [ SqlColumnNumber = 20 ];

Property errorStatus As %String(MAXLEN = 20) [ SqlColumnNumber = 21 ];

Property errorMessage As %String(MAXLEN = 10000) [ SqlColumnNumber = 22 ];

Property archived As %String(MAXLEN = 10) [ SqlColumnNumber = 23 ];

Property emailStatus As %Integer(DISPLAYLIST = ",Envoyé, Erreur lors de l'envoi, Pas de destinataire", VALUELIST = ",0,1,2") [ SqlColumnNumber = 24 ];

Property emailDate As %String [ SqlColumnNumber = 25 ];

ClassMethod save(data As %Library.DynamicArray, match As %Integer) As %Status
{
	set newLine 			= ..%New()
	set newLine.confFileName	= $Piece(data.confFileName,".",1)
	set newLine.contrat		= data.contrat
	set newLine.tradeDate	= data.tradeDate
	set newLine.valueDate	= data.valueDate
	set newLine.maturityDate= data.maturityDate
	set newLine.spot		= data.spot
	set newLine.term		= data.term
	set newLine.amountReceived	= data.amountReceived
	set newLine.amountPaid	= data.amountPaid
	set newLine.deviseReceived	= data.deviseReceived
	set newLine.devisePaid	= data.devisePaid
	set newLine.bank		= data.bank
	set newLine.confType	= data.confType
	set newLine.matchDate	= data.matchDate
	set newLine.emailStatus	= ""
	set newLine.archived	= 0
	
	If match = 1 {
		set newLine.idForex = data.idForex
		set newLine.idEaiForex = data.idEaiForex
		set newLine.matchStatus = 1
		set newLine.errorStatus = 0
		set newLine.errorMessage = 0
	}

	If match = 0 {
		set newLine.matchStatus = 0
		set newLine.errorStatus = 0
		set newLine.errorMessage = 0
	}

	If match > 1 {
		set newLine.matchStatus = 0
		set newLine.errorStatus = 2
		set newLine.errorMessage = "Plusieurs demandes trouvées"
	}
	
	set tSC = newLine.%Save()

	If 'tSC quit tSC

	quit newLine.%Id()
}

ClassMethod match(data As %Library.DynamicArray) As %Status
{
	if data.idEaiBank = "" quit "The Id in the data provided is null"
	if 'data.match quit 1

	set line = ..%OpenId(data.idEaiBank)

	set line.matchStatus = 1
	set line.idForex = data.idForex
	set line.idEaiForex = data.idEaiForex

	set tSC = line.%Save()

	quit tSC
}

Storage Default
{
<Data name="bankDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>idForex</Value>
</Value>
<Value name="3">
<Value>idEaiForex</Value>
</Value>
<Value name="4">
<Value>confFileName</Value>
</Value>
<Value name="5">
<Value>contrat</Value>
</Value>
<Value name="6">
<Value>UsiUti</Value>
</Value>
<Value name="7">
<Value>tradeDate</Value>
</Value>
<Value name="8">
<Value>valueDate</Value>
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
<Value>amountPaid</Value>
</Value>
<Value name="14">
<Value>deviseReceived</Value>
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
<Value>confType</Value>
</Value>
<Value name="19">
<Value>matchStatus</Value>
</Value>
<Value name="20">
<Value>matchDate</Value>
</Value>
<Value name="21">
<Value>errorStatus</Value>
</Value>
<Value name="22">
<Value>errorMessage</Value>
</Value>
<Value name="23">
<Value>archived</Value>
</Value>
<Value name="24">
<Value>emailStatus</Value>
</Value>
<Value name="25">
<Value>emailDate</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeConAB75.bankD</DataLocation>
<DefaultData>bankDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofficeConAB75.bankD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeConAB75.bankI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeConAB75.bankS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

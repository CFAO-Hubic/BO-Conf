Class CFAO.HUBIC.BofficeConf.Table.JrnForexRecords Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property Filename As %String(MAXLEN = 2000);

Property IDForex As %String [ SqlColumnNumber = 2 ];

Property TRADEDATE As %String(MAXLEN = 10) [ SqlColumnNumber = 3 ];

Property CPTYSHORTNAME As %String(MAXLEN = 5) [ SqlColumnNumber = 4 ];

Property CURRENCY1SHORTNAME As %String(MAXLEN = 5) [ SqlColumnNumber = 5 ];

Property TRADETYPESHORTNAME As %String(MAXLEN = 5) [ SqlColumnNumber = 6 ];

Property AMOUNT1 As %String [ SqlColumnNumber = 7 ];

Property CLIENTRATE As %String [ SqlColumnNumber = 8 ];

Property AMOUNT2 As %String [ SqlColumnNumber = 9 ];

Property REMAININGAMOUNT1 As %String [ SqlColumnNumber = 10 ];

Property APPLICATIVESTATUSNAME As %String [ SqlColumnNumber = 11 ];

Property REFERENCE As %String [ SqlColumnNumber = 12 ];

Property VALUEDATE As %String(MAXLEN = 10) [ SqlColumnNumber = 13 ];

Property MATURITYDATE As %String(MAXLEN = 10) [ SqlColumnNumber = 14 ];

Property SPOTRATE As %String [ SqlColumnNumber = 15 ];

Property UTICCI As %String(MAXLEN = 500) [ SqlColumnNumber = 16 ];

Property PARENTTRADECCE As %String [ SqlColumnNumber = 17 ];

Property SensVouA As %String(MAXLEN = 1) [ SqlColumnNumber = 18 ];

Property DateTraitement As %String [ SqlColumnNumber = 19 ];

Property DateTraitementTimeStamp As %String [ SqlColumnNumber = 20 ];

Property rapprocherOUINON As %String(MAXLEN = 10) [ SqlColumnNumber = 21 ];

Property StatutHistoForex As %String(MAXLEN = 3) [ SqlColumnNumber = 22 ];

Property UTIbanques As %String(MAXLEN = 100) [ SqlColumnNumber = 23 ];

Property DateRapprochement As %String [ SqlColumnNumber = 24 ];

Property TypeRapprochement As %String(MAXLEN = 10) [ SqlColumnNumber = 25 ];

Property TypeConfirmation As %String(MAXLEN = 20) [ SqlColumnNumber = 26 ];

Property DateHistoF As %String [ SqlColumnNumber = 27 ];

Property ErreurJrnForex As %String(MAXLEN = 100) [ SqlColumnNumber = 28 ];

Property NomConfirmation As %String(MAXLEN = 300) [ SqlColumnNumber = 29 ];

Property RefBanques As %String [ SqlColumnNumber = 30 ];

Property DateEnvoiMail As %String [ SqlColumnNumber = 31 ];

Property CURRENCY2SHORTNAME As %String [ SqlColumnNumber = 32 ];

ClassMethod SaveRapproLigneJRN(DateTraitTIMESTAMP As %String, IdEAIJrnForex As %String, NbRapproche As %Integer, NomDuFichierConfirmation As %String, RefBanques As %String) As %Status
{
	
	Set ErrorBo = "OK"
	Set ErrorBoDescription = "OK"
	If IdEAIJrnForex '= "" {
		If NbRapproche = 1 {		
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(IdEAIJrnForex)
			Set LaLigneJrnForex.rapprocherOUINON = "OUI"
			Set LaLigneJrnForex.TypeRapprochement = "AUTO"
			Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
			If LaLigneJrnForex.NomConfirmation = "" {
				Set LaLigneJrnForex.NomConfirmation = $Replace($Piece(NomDuFichierConfirmation,".",1) _ ".pdf"," ","_")
			}Else{
				Set LaLigneJrnForex.NomConfirmation = LaLigneJrnForex.NomConfirmation _ "-" _$Replace($Piece(NomDuFichierConfirmation,".",1) _ ".pdf"," ","_")
			}
			If LaLigneJrnForex.RefBanques = "" {
				Set LaLigneJrnForex.RefBanques = RefBanques
			}Else{
				Set LaLigneJrnForex.RefBanques = LaLigneJrnForex.RefBanques _ "-" _RefBanques
			}
						
			Set MajLigneJrnForexStatut =  LaLigneJrnForex.%Save()
			If ('MajLigneJrnForexStatut){
				Set ErrorBo = "WAR"
	    		Set ErrorBoDescription = ErrorBoDescription _ NomBanquesCB _ "-" _ TypeConfirmationCB _ " : Erreur de mise a jour du statut rapporchement JrnForex pour ID Forex : "_IDForex_"!@@!"
		}	
			
		}elseIf NbRapproche = 9999{ // Cas particulier pour les PRORO SPOT et TERME
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(IdEAIJrnForex)
			Set LaLigneJrnForex.TypeRapprochement = "Premier"
			Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
			If LaLigneJrnForex.NomConfirmation = "" {
				Set LaLigneJrnForex.NomConfirmation = $Replace($Piece(NomDuFichierConfirmation,".",1) _ ".pdf"," ","_")
			}Else{
				Set LaLigneJrnForex.NomConfirmation = LaLigneJrnForex.NomConfirmation _ "-" _$Replace($Piece(NomDuFichierConfirmation,".",1) _ ".pdf"," ","_")
			}
			If LaLigneJrnForex.RefBanques = "" {
				Set LaLigneJrnForex.RefBanques = RefBanques
			}Else{
				Set LaLigneJrnForex.RefBanques = LaLigneJrnForex.RefBanques _ "-" _RefBanques
			}
			Set MajLigneJrnForexStatut =  LaLigneJrnForex.%Save()
			If ('MajLigneJrnForexStatut){
				Set ErrorBo = "WAR"
	    		Set ErrorBoDescription = ErrorBoDescription _ NomBanquesCB _ "-" _ TypeConfirmationCB _ " : Erreur de mise a jour du statut rapporchement JrnForex pour ID Forex : "_IDForex_"!@@!"
			}
				
		}
			
	}	
	
	Set ReturnTag = ErrorBo _ "!##! " _ ErrorBoDescription
		
	Quit ReturnTag
}

Storage Default
{
<Data name="JrnForexRecordsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Filename</Value>
</Value>
<Value name="3">
<Value>IDForex</Value>
</Value>
<Value name="4">
<Value>TRADEDATE</Value>
</Value>
<Value name="5">
<Value>CPTYSHORTNAME</Value>
</Value>
<Value name="6">
<Value>CURRENCY1SHORTNAME</Value>
</Value>
<Value name="7">
<Value>TRADETYPESHORTNAME</Value>
</Value>
<Value name="8">
<Value>AMOUNT1</Value>
</Value>
<Value name="9">
<Value>CLIENTRATE</Value>
</Value>
<Value name="10">
<Value>AMOUNT2</Value>
</Value>
<Value name="11">
<Value>REMAININGAMOUNT1</Value>
</Value>
<Value name="12">
<Value>APPLICATIVESTATUSNAME</Value>
</Value>
<Value name="13">
<Value>REFERENCE</Value>
</Value>
<Value name="14">
<Value>VALUEDATE</Value>
</Value>
<Value name="15">
<Value>MATURITYDATE</Value>
</Value>
<Value name="16">
<Value>SPOTRATE</Value>
</Value>
<Value name="17">
<Value>UTICCI</Value>
</Value>
<Value name="18">
<Value>PARENTTRADECCE</Value>
</Value>
<Value name="19">
<Value>SensVouA</Value>
</Value>
<Value name="20">
<Value>DateTraitement</Value>
</Value>
<Value name="21">
<Value>DateTraitementTimeStamp</Value>
</Value>
<Value name="22">
<Value>rapprocherOUINON</Value>
</Value>
<Value name="23">
<Value>StatutHistoForex</Value>
</Value>
<Value name="24">
<Value>UTIbanques</Value>
</Value>
<Value name="25">
<Value>DateRapprochement</Value>
</Value>
<Value name="26">
<Value>TypeRapprochement</Value>
</Value>
<Value name="27">
<Value>TypeConfirmation</Value>
</Value>
<Value name="28">
<Value>DateHistoF</Value>
</Value>
<Value name="29">
<Value>ErreurJrnForex</Value>
</Value>
<Value name="30">
<Value>NomConfirmation</Value>
</Value>
<Value name="31">
<Value>RefBanques</Value>
</Value>
<Value name="32">
<Value>DateEnvoiMail</Value>
</Value>
<Value name="33">
<Value>CURRENCY2SHORTNAME</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBICF369.JrnForexRec6AB2D</DataLocation>
<DefaultData>JrnForexRecordsDefaultData</DefaultData>
<IdLocation>^CFAO.HUBICF369.JrnForexRec6AB2D</IdLocation>
<IndexLocation>^CFAO.HUBICF369.JrnForexRec6AB2I</IndexLocation>
<StreamLocation>^CFAO.HUBICF369.JrnForexRec6AB2S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

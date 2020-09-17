Class CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques Extends %Persistent
{

Property FilenameCB As %String(MAXLEN = 2000) [ SqlColumnNumber = 2 ];

Property ContratCB As %String [ SqlColumnNumber = 3 ];

Property USIUTICB As %String(MAXLEN = 50) [ SqlColumnNumber = 4 ];

Property DateNegoceCB As %String(MAXLEN = 50) [ SqlColumnNumber = 5 ];

Property DateValeurCB As %String(MAXLEN = 50) [ SqlColumnNumber = 6 ];

Property CoursDeChangeCB As %String(MAXLEN = 50) [ SqlColumnNumber = 8 ];

Property AcheterMontantCB As %String(MAXLEN = 50) [ SqlColumnNumber = 10 ];

Property VenduMontantCB As %String(MAXLEN = 50) [ SqlColumnNumber = 11 ];

Property AcheterDeviseCB As %String(MAXLEN = 50) [ SqlColumnNumber = 12 ];

Property VenduDeviseCB As %String(MAXLEN = 50) [ SqlColumnNumber = 13 ];

Property SensCB As %String(MAXLEN = 50) [ SqlColumnNumber = 14 ];

Property DeviseCB As %String(MAXLEN = 50) [ SqlColumnNumber = 15 ];

Property MontantDeviseCB As %String(MAXLEN = 50) [ SqlColumnNumber = 16 ];

Property NomBanquesCB As %String(MAXLEN = 20) [ SqlColumnNumber = 17 ];

Property TypeConfirmationCB As %String(MAXLEN = 20) [ SqlColumnNumber = 18 ];

Property StatutRapprocherCB As %String(MAXLEN = 10) [ SqlColumnNumber = 19 ];

Property DateTraitementCB As %String(MAXLEN = 20) [ SqlColumnNumber = 20 ];

Property DateTraitementTimeStampCB As %String(MAXLEN = 20) [ SqlColumnNumber = 21 ];

/// IdForex du fichier jouranl Forex
Property IDforexCB As %String(MAXLEN = 50) [ SqlColumnNumber = 22 ];

/// Id interne a l'EAi de la ligne du Journal Forex
Property IdEAIJrnForexCB As %String(MAXLEN = 50) [ SqlColumnNumber = 23 ];

Property StatutErrorCB As %String(MAXLEN = 20) [ SqlColumnNumber = 24 ];

Property DescErrorCB As %String(MAXLEN = 10000) [ SqlColumnNumber = 25 ];

Property StatutEnvoiHistoCB As %String(MAXLEN = 10) [ SqlColumnNumber = 26 ];

Property StatutEnvoiMailCB As %String [ SqlColumnNumber = 27 ];

Property NomPieceJointe As %String(MAXLEN = 2000) [ SqlColumnNumber = 28 ];

Property DateEnvoiMail As %String [ SqlColumnNumber = 29 ];

Property NomJournalForex As %String(MAXLEN = 500) [ SqlColumnNumber = 30 ];

Property MaturityDate As %String(MAXLEN = 50) [ SqlColumnNumber = 31 ];

Property TauxTerme As %String(MAXLEN = 50) [ SqlColumnNumber = 32 ];

// Si la confirmation de banque est rapprochée , on enregistre OUI pour le champ StatutRapprocherCB

ClassMethod SaveConfBanque(FilenameCB As %String, ContratCB As %String, DateNegoceCB As %String, DateValeurCB As %String, CoursDeChangeCB As %String, AcheterMontantCB As %String, VenduMontantCB As %String, AcheterDeviseCB As %String, VenduDeviseCB As %String, SensCB As %String, DeviseCB As %String, MontantDeviseCB As %String, NomBanquesCB As %String, TypeConfirmationCB As %String, DateTraitementCB As %String, DateTraitementTimeStampCB As %String, IDForex As %String, IdEAIJrnForex As %String, NbRapproche As %Integer, ErrorBo As %String) As %Status
{
	
	Set ErrorBoDescription = "OK"
	
	Set LaConfirmationBanques =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%New()
	Set LaConfirmationBanques.FilenameCB = FilenameCB
	Set LaConfirmationBanques.ContratCB = ContratCB	
	Set LaConfirmationBanques.DateNegoceCB = DateNegoceCB
	Set LaConfirmationBanques.DateValeurCB = DateValeurCB
	Set LaConfirmationBanques.CoursDeChangeCB = CoursDeChangeCB
	Set LaConfirmationBanques.AcheterMontantCB = AcheterMontantCB
	Set LaConfirmationBanques.VenduMontantCB = VenduMontantCB
	Set LaConfirmationBanques.AcheterDeviseCB = AcheterDeviseCB
	Set LaConfirmationBanques.VenduDeviseCB = VenduDeviseCB
	Set LaConfirmationBanques.SensCB = SensCB
	Set LaConfirmationBanques.DeviseCB = DeviseCB
	Set LaConfirmationBanques.MontantDeviseCB = MontantDeviseCB		
	Set LaConfirmationBanques.NomBanquesCB = NomBanquesCB // Entité du journal forex
	Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmationCB	
	Set LaConfirmationBanques.DateTraitementCB = DateTraitementCB // format "YYYYMMJJ" 
	Set LaConfirmationBanques.DateTraitementTimeStampCB = DateTraitementTimeStampCB
	Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	Set LaConfirmationBanques.StatutEnvoiMailCB = "NON"
	Set LaConfirmationBanques.StatutEnvoiHistoCB = "NON"
	Set LaConfirmationBanques.NomPieceJointe = $Piece(FilenameCB,".",1) _ ".pdf"
	
	If NbRapproche = 1 {
		//Information contenu dans la ligne de Jouranl Foraex a rajouter sur la ligne des banques
		Set LaConfirmationBanques.IDforexCB = IDForex
		Set LaConfirmationBanques.IdEAIJrnForexCB = IdEAIJrnForex
		Set LaConfirmationBanques.StatutRapprocherCB = "OUI"

		//Enregistrement du statut des erreurs et de leurs descriptions
		Set LaConfirmationBanques.StatutErrorCB = "0"
		Set LaConfirmationBanques.DescErrorCB = "0"		
	}
	If NbRapproche = 0 {
		Set LaConfirmationBanques.StatutErrorCB = "0"
		Set LaConfirmationBanques.DescErrorCB = "0"
		Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	}
	If NbRapproche > 1 {
		Set LaConfirmationBanques.StatutErrorCB = "2"
		Set LaConfirmationBanques.DescErrorCB = "plusieurs demandes trouvées"
		Set ErrorBo = "ERR"
	}
	
	If ErrorBo = "ERR"{
		Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	}	
	Set EnregConfBanquesStatut = LaConfirmationBanques.%Save()
	//$$$LOGINFO("EnregConfBanquesStatut CB :"_EnregConfBanquesStatut)	
	Set varIdEaiConf = LaConfirmationBanques.%Id()
	
	
	
	If ('EnregConfBanquesStatut){
		Set ErrorBo = "ERR"
	    Set ErrorBoDescription = ErrorBoDescription _ NomBanquesCB _ "-" _ TypeConfirmationCB _ " : Erreur de sauvegarde de la confirmation pour le contrat: "_ContratCB_"!@@!"
	}	
	
	Set ReturnTag = ErrorBo _ "!##!" _ ErrorBoDescription _ "!##!" _ varIdEaiConf
	
	Quit ReturnTag
}

Storage Default
{
<Data name="ConfirmationBanquesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FilenameCB</Value>
</Value>
<Value name="3">
<Value>ContratCB</Value>
</Value>
<Value name="4">
<Value>USIUTICB</Value>
</Value>
<Value name="5">
<Value>DateNegoceCB</Value>
</Value>
<Value name="6">
<Value>DateValeurCB</Value>
</Value>
<Value name="7">
<Value>CoursDeChangeCB</Value>
</Value>
<Value name="8">
<Value>AcheterMontantCB</Value>
</Value>
<Value name="9">
<Value>VenduMontantCB</Value>
</Value>
<Value name="10">
<Value>AcheterDeviseCB</Value>
</Value>
<Value name="11">
<Value>VenduDeviseCB</Value>
</Value>
<Value name="12">
<Value>SensCB</Value>
</Value>
<Value name="13">
<Value>DeviseCB</Value>
</Value>
<Value name="14">
<Value>MontantDeviseCB</Value>
</Value>
<Value name="15">
<Value>NomBanquesCB</Value>
</Value>
<Value name="16">
<Value>TypeConfirmationCB</Value>
</Value>
<Value name="17">
<Value>StatutRapprocherCB</Value>
</Value>
<Value name="18">
<Value>DateTraitementCB</Value>
</Value>
<Value name="19">
<Value>DateTraitementTimeStampCB</Value>
</Value>
<Value name="20">
<Value>IDforexCB</Value>
</Value>
<Value name="21">
<Value>IdEAIJrnForexCB</Value>
</Value>
<Value name="22">
<Value>StatutErrorCB</Value>
</Value>
<Value name="23">
<Value>DescErrorCB</Value>
</Value>
<Value name="24">
<Value>StatutEnvoiHistoCB</Value>
</Value>
<Value name="25">
<Value>StatutEnvoiMailCB</Value>
</Value>
<Value name="26">
<Value>NomPieceJointe</Value>
</Value>
<Value name="27">
<Value>DateEnvoiMail</Value>
</Value>
<Value name="28">
<Value>NomJournalForex</Value>
</Value>
<Value name="29">
<Value>MaturityDate</Value>
</Value>
<Value name="30">
<Value>TauxTerme</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBICF369.Confirmatio5E4ED</DataLocation>
<DefaultData>ConfirmationBanquesDefaultData</DefaultData>
<IdLocation>^CFAO.HUBICF369.Confirmatio5E4ED</IdLocation>
<IndexLocation>^CFAO.HUBICF369.Confirmatio5E4EI</IndexLocation>
<StreamLocation>^CFAO.HUBICF369.Confirmatio5E4ES</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

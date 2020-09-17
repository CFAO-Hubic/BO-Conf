Class CFAO.HUBIC.BofficeConf.BO.CSVrepot.DepotReportingCSV Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

Property ListTypeOperation As %String [ InitialExpression = "EAAT,EVAT,EVSP,EVSPA,EASP,EASPA,ERAT,ERVT,ELAT,ELATA,ELVT,ELVTA,SWAVF,SWAAF" ];

Parameter INVOCATION = "Queue";

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method OnMessage(pRequest As CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV, Output pResponse As Ens.StringResponse) As %Status
{
  
  	
  	// Instanciation de la Response ***********************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""
	// ****************************************************************************************************************
  	
  	Set NbMEP = 0
  	Set NbLEVEE = 0
  	
  	set File = ##class(%Stream.FileCharacter).%New()
	set File.Filename = pRequest.%Source
  	
  	Set ParentBatch = pRequest.%Id()
  	//$$$LOGINFO("ParentBatch "_ParentBatch) 
  	Set NomDuFichierCSV = $Piece($Replace(pRequest.%Source,"-","/"),"_",2)
  	Set NomDuFichierCSV = $Piece(NomDuFichierCSV,"/",3)_"/"_$Piece(NomDuFichierCSV,"/",2)_"/"_$Piece(NomDuFichierCSV,"/",1)
  	//$$$LOGINFO("NomDuFichierCSV "_NomDuFichierCSV) 	
  	
  	Set TitreCSV = ";;JOURNEE DU "_NomDuFichierCSV_";;;;;;"
  	do File.WriteLine(TitreCSV)
  	
  	//On verifie si des MEP sont présentes
  	&SQL(SELECT count(*) INTO NbMEP FROM CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record where TypeTableau = 'MEP' and %ParentBatch = :ParentBatch)
  	
  	If NbMEP > 0 {
	  	do File.WriteLine(";;;;;;;;")
	  	do File.WriteLine("MISE EN PLACE;;;;;;;;")
	  	do File.WriteLine("Devises;Type d'opé;cpty;Devise;Spot;Cours Terme;Echéance;EUR;Total")
	  	set key = pRequest.Records.Next()
	  	while(key '= "")
	  	{
		  	// Info en provenance de la table JournalForexEmir
		  	set refinterne = pRequest.Records.GetAt(key).refinterne
		  	//$$$LOGINFO("key "_key_" : "_refinterne)
		  
		  	If pRequest.Records.GetAt(key).TypeTableau = "MEP" {
			  	Set Devise = pRequest.Records.GetAt(key).Devises
			  	Set TypeOpe = pRequest.Records.GetAt(key).TypeOpe
			  	Set cpty = pRequest.Records.GetAt(key).cpty
			  	Set DeviseMontant = pRequest.Records.GetAt(key).DeviseMontant
			  	Set Spot = pRequest.Records.GetAt(key).Spot
			  	Set CoursTerme = pRequest.Records.GetAt(key).CoursTerme
			  	Set Echeance = pRequest.Records.GetAt(key).Echeance
			  	Set EURmontant = pRequest.Records.GetAt(key).EURmontant
			  	Set TotalDevise = pRequest.Records.GetAt(key).TotalDevise
			  	Set LigneMEP = Devise_";"_TypeOpe_";"_cpty_";"_DeviseMontant_";"_Spot_";"_CoursTerme_";"_Echeance_";"_EURmontant_";"_TotalDevise
			  	do File.WriteLine(LigneMEP)
			  	
		  	}
		  	set key = pRequest.Records.Next(key)
	  	}
  	}
	
	//On verifie si des LEVEE sont présentes
  	&SQL(SELECT count(*) INTO NbLEVEE FROM CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record where TypeTableau = 'LEVEE' and %ParentBatch = :ParentBatch)
	
	If NbLEVEE > 0 {
		do File.WriteLine(";;;;;;;;")
		do File.WriteLine("LEVEE;;;;;;;;")
		do File.WriteLine("Devises;Type d'opé;cpty;Devise;Spot;Cours Initial;Contrevaleur EUR;Date de valeur;Total Devise;Total EUR")
	  	set key = pRequest.Records.Next()
	  	while(key '= "")
	  	{
		  	// Info en provenance de la table JournalForexEmir
		  	set refinterne = pRequest.Records.GetAt(key).refinterne
		  	//$$$LOGINFO("key "_key_" : "_refinterne)
		  
		  	If pRequest.Records.GetAt(key).TypeTableau = "LEVEE" {
			  	Set Devise = pRequest.Records.GetAt(key).Devises
			  	Set TypeOpe = pRequest.Records.GetAt(key).TypeOpe
			  	Set cpty = pRequest.Records.GetAt(key).cpty
			  	Set DeviseMontant = pRequest.Records.GetAt(key).DeviseMontant
			  	Set Spot = pRequest.Records.GetAt(key).Spot
			  	Set CoursTerme = pRequest.Records.GetAt(key).CoursTerme
			  	Set Echeance = pRequest.Records.GetAt(key).Echeance
			  	Set EURmontant = pRequest.Records.GetAt(key).EURmontant
			  	Set TotalDevise = pRequest.Records.GetAt(key).TotalDevise
			  	Set TotalEUR = pRequest.Records.GetAt(key).TotalEUR
			  	Set LigneLEVEE = Devise_";"_TypeOpe_";"_cpty_";"_DeviseMontant_";"_Spot_";"_CoursTerme_";"_Echeance_";"_EURmontant_";"_TotalDevise_";"_TotalEUR
			  	do File.WriteLine(LigneLEVEE)
			  	
		  	}
		  	set key = pRequest.Records.Next(key)
	  	} 	  
	} 
	set tSC = File.Rewind()	
	Set tSC = ..Adapter.PutStream(pRequest.%Source,File)
	
	If (tSC) Set pResponse.StringValue = 0
	If ('tSC) Set pResponse.StringValue = 1
	
	quit pResponse
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV"> 
		<Method>OnMessage</Method>
	</MapItem>
</MapItems>
}

}

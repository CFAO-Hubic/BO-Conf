Class CFAO.HUBIC.BofficeConf.BS.RecupconfBanqueTXT Extends EnsLib.File.PassthroughService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Property TargetConfigNames As %String;

Parameter SETTINGS = "TargetConfigNames";

/// Wrap the input stream object in a StreamContainer message object and send it.
/// If the adapter has a value for ArchivePath, send async; otherwise send synchronously
/// to ensure that we don't return to the Adapter and let it delete the file before the
/// target Config Item is finished processing it.
Method OnProcessInput(pInput As %Stream.Object, pOutput As %RegisteredObject) As %Status
{
	
	Set pRequest = ##class(%Stream.FileCharacter).%New()
	Set LineNomDuFichier = pInput.Attributes("Filename")
	
	Set LineNomDuFichier = $Piece(LineNomDuFichier,"\",$Length(LineNomDuFichier,"\"))
	//$$$LOGINFO("LineNomDuFichier :"_LineNomDuFichier)
	
	
	Do pRequest.WriteLine(LineNomDuFichier)
	While 'pInput.AtEnd {
		Set Line = pInput.ReadLine()
		//$$$LOGINFO("Line :"_Line)
		Do pRequest.WriteLine(Line)	
	}
	Do pRequest.%Save()	
	
	
	
	Set tSource=pInput.Attributes("Filename"), pInput=$zobjclassmethod(..#CONTAINERCLASS,"%New",pInput)	
	Set tSC=..resolveAndIndex(pInput) Quit:$$$ISERR(tSC) tSC
	Set tWorkArchive=(""'=..Adapter.ArchivePath)&&(..Adapter.ArchivePath=..Adapter.WorkPath || (""=..Adapter.WorkPath && (..Adapter.ArchivePath=..Adapter.FilePath)))
	$$$SyncCommitSet(tSyncCommit)
	For iTarget=1:1:$L(..TargetConfigNames, ",") { Set tOneTarget=$ZStrip($P(..TargetConfigNames,",",iTarget),"<>W")  Continue:""=tOneTarget
		//$$$sysTRACE("Sending input Stream "_pInput.Stream_"("_pInput.Stream.Size_")"_$S(tWorkArchive:" Async",1:" Sync")_" from '"_tSource_"' to '"_tOneTarget_"'")
		//$$$sysTRACE("Sending input Stream "_pInput.Stream_"("_pInput.Stream.Size_")"_$S(tWorkArchive:" Async",1:" Sync")_" from '"_tSource_"' to '"_tOneTarget_"'")
		If tWorkArchive {
			//Set tSC1=..SendRequestAsync(tOneTarget,pInput)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
			Set tSC1=..SendRequestAsync(tOneTarget,pRequest)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
		} Else {
			#; If not archiving send Sync to avoid Adapter deleting file before Operation gets it
			//Set tSC1=..SendRequestSync(tOneTarget,pInput)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
			Set tSC1=..SendRequestSync(tOneTarget,pRequest)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
		}
	}
	
	$$$SyncCommitClear(tSyncCommit)
	
	Quit tSC
}

/// cette methode fait le lien entre le BS et sa Cible target
ClassMethod OnGetConnections(pArray As %String, item As Ens.Config.Item) As %Status
{
	Set (tValue,tIndex)="" For { Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""  Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" Set tValue=tSetting.Value  Quit
	}
	For i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
}

}

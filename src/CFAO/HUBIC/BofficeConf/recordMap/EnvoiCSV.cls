/// RECORDMAP: Modified during compilation of RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV'
/// on 2017-01-09 at 13:03:48.509 [2017-01-09 12:03:48.509 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV Extends EnsLib.RecordMap.RecordMap
{

/// Method to retrieve a record from a stream or device. This method will be generated based on the
/// structure of the RecordMap. For testing purposes, a file name may be passed in the pStream argument.
ClassMethod GetObject(pStream As %IO.DeviceStream, Output pObject As %RegisteredObject, pTimeout As %Numeric = -1, ByRef pLookAhead As %String = "", pLabelFound As %Boolean = 0) As %Status
{
	Try {
		Set tStatus = $$$OK
		Set pObject = $$$NULLOREF
		If '$IsObject(pStream) {
			Set tFilename = pStream
			Set pStream = ##class(%IO.FileStream).%New()
			Do pStream.Open(tFilename,,pTimeout,"UTF-8", .tStatus)
			If $$$ISERR(tStatus) Quit
		}
		Set tObjectName = $parameter($this,"OBJECTNAME")
		Set tObject = $classmethod(tObjectName,"%New")
		If '$IsObject(tObject) {
			Set tStatus = $$$ERROR($$$CannotCreateObject,tObjectName)
			Quit
		}
		Set tObject.%Source = pStream.Name
		Set tGetTopFields = $parameter(tObject,"INCLUDETOPFIELDS")
		If pStream.AtEnd {
			Set tStatus = $$$ERROR($$$EnsRecordMapErrStreamAtEnd, pStream.Name)
			Quit
		}
		Set pStream.CharEncoding = "UTF-8"

		#; Parse incoming stream
		Set tStatus = ..GetRecord(pStream, tObject, tGetTopFields, pTimeout, .pLookAhead, pLabelFound)
		If $$$ISERR(tStatus) Quit
	}
	Catch ex {
		Set tStatus = ex.AsStatus()
	}
	If $$$ISERR(tStatus) { Set pObject = $$$NULLOREF }
	Else { Set pObject = tObject }
	Quit tStatus
}

/// Method to write a record to a stream or device. This method will be generated based on the
/// structure of the RecordMap. For testing purposes, a file name may be passed in the pStream argument.
ClassMethod PutObject(pStream As %IO.DeviceStream, pObject As %RegisteredObject, pFlush As %Boolean = 1, ByRef pPadArray As %String) As %Status
{
	Try {
		Set tStatus = $$$OK
		If '$IsObject(pStream) {
			Set tFilename = pStream
			Set pStream = ##class(%IO.FileStream).%New()
			Do pStream.Open(tFilename,"WAE",,"UTF-8", .tStatus)
			If $$$ISERR(tStatus) Quit
		}
		Set tHasTopFields = $parameter(pObject,"INCLUDETOPFIELDS")
		Set pStream.CharEncoding = "UTF-8"

		Set tStatus = ..PutRecord(pStream, pObject, tHasTopFields, .pPadArray)
		If $$$ISERR(tStatus) Quit
		If pFlush Do pStream.Flush(.tStatus)
		If $$$ISERR(tStatus) Quit
	}
	Catch ex {
		Set tStatus = ex.AsStatus()
	}
	Quit tStatus
}

Parameter OBJECTNAME = "CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record";

/// Internal helper method to perform parse of incoming data
ClassMethod GetRecord(pStream As %IO.DeviceStream, pObject As %RegisteredObject, pGetTopFields As %Boolean, pTimeout As %Numeric, ByRef pLookAhead As %String = "", pLabelFound As %Boolean = 0) As %Status [ Internal, Private ]
{
	Set tStatus = $$$OK
	If pLabelFound { Set tRecLabel = "" } 
	Else { Set tRecLabel = "" } 
	Set tStatus = ..chunkRecord(pStream, .tRecordData, .tCharCount, "", pTimeout, $char(13,10), tRecLabel, .pLookAhead, "")
	If $$$ISERR(tStatus) Quit tStatus
	Set tMaxLocal = $$$MaxLocalLength
	Set tRecordData("charcount") = +$get(tCharCount)
	Set tCurrChunk = 1
	Set tTopPiece = 1
	Set tCurrSep = 1
	Set tStrings = 1
	Set tSeps = $listbuild($char(44))
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Else {
		Set tCurrString = tRecordData(tCurrChunk)
		Set tCurrPiece = 1
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.refinterne = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.Devises = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TypeOpe = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.cpty = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.DeviseMontant = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.Spot = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.CoursTerme = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.Echeance = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.EURmontant = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TotalDevise = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.DateValeur = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TotalEUR = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TotalDeviseGlobal = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TotalEURGlobal = tCurrString
	}
	If '$data(tRecordData(tCurrChunk, "block")) {
		Set tCurrString = $piece(tRecordData(tCurrChunk), $char(44), tTopPiece)
	}
	Do ..checkMerge(.tCurrChunk, .tRecordData, .tCurrString, $char(44), .tTopPiece)
	If pGetTopFields {
		Set pObject.TypeTableau = tCurrString
	}
	Quit tStatus
}

/// Internal helper method to output object to a stream
ClassMethod PutRecord(pStream As %IO.DeviceStream, pObject As %RegisteredObject, pHasTopFields As %Boolean, ByRef pPadArray As %String) As %Status [ Internal, Private ]
{
	Set tStatus = $$$OK
	Do pStream.Write($select(pHasTopFields: pObject.refinterne,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.Devises,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TypeOpe,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.cpty,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.DeviseMontant,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.Spot,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.CoursTerme,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.Echeance,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.EURmontant,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TotalDevise,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.DateValeur,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TotalEUR,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TotalDeviseGlobal,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TotalEURGlobal,1: ""),0)
	Do pStream.Write($char(44) _ $select(pHasTopFields: pObject.TypeTableau,1: ""),0)
	Do pStream.Write($char(13,10), 0, .tStatus)
	If $$$ISERR(tStatus) Quit tStatus
	Quit tStatus
}

ClassMethod GetGeneratedClasses(Output pClasses As %String) As %Status
{
	Kill pClasses
	Set pClasses("CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV")=""
	Set pClasses("CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record")=""
	Set pClasses($classname())=""
	Quit $$$OK
}

ClassMethod getIdentifier() As %String [ CodeMode = expression ]
{
""
}

ClassMethod getType() As EnsLib.RecordMap.Model.DataType.RecordType [ CodeMode = expression ]
{
"delimited"
}

XData RecordMap [ XMLNamespace = "http://www.intersystems.com/Ensemble/RecordMap" ]
{
<Record xmlns="http://www.intersystems.com/Ensemble/RecordMap" name="CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV" type="delimited" char_encoding="UTF-8" targetClassname="CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record" batchClass="CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV" complexBatchManaged="0" padFromLeft="0" recordTerminator="\x0d\x0a" allowEarlyTerminator="0">
  <Separators>
    <Separator>,</Separator>
  </Separators>
  <Field name="refinterne" required="0" datatype="%String" sqlColumn="2" repeating="0">
  </Field>
  <Field name="Devises" required="0" datatype="%String" sqlColumn="3" repeating="0">
    <annotation>CURRENCY1SHORTNAME</annotation>
  </Field>
  <Field name="TypeOpe" required="0" datatype="%String" sqlColumn="4" repeating="0">
    <annotation>TRADETYPESHORTNAME</annotation>
  </Field>
  <Field name="cpty" required="0" datatype="%String" sqlColumn="5" repeating="0">
    <annotation>CPTYSHORTNAME</annotation>
  </Field>
  <Field name="DeviseMontant" required="0" datatype="%String" sqlColumn="6" repeating="0">
    <annotation>AMOUNT1</annotation>
  </Field>
  <Field name="Spot" required="0" datatype="%String" sqlColumn="7" repeating="0">
    <annotation>SPOTRATE</annotation>
  </Field>
  <Field name="CoursTerme" required="0" datatype="%String" sqlColumn="9" repeating="0">
    <annotation>CLIENTRATE</annotation>
  </Field>
  <Field name="Echeance" required="0" datatype="%String" sqlColumn="10" repeating="0">
    <annotation>MATURITYDATE</annotation>
  </Field>
  <Field name="EURmontant" required="0" datatype="%String" sqlColumn="11" repeating="0">
    <annotation>AMOUNT2</annotation>
  </Field>
  <Field name="TotalDevise" required="0" datatype="%String" sqlColumn="12" repeating="0">
  </Field>
  <Field name="DateValeur" required="0" datatype="%String" sqlColumn="13" repeating="0">
    <annotation>VALUEDATE</annotation>
  </Field>
  <Field name="TotalEUR" required="0" datatype="%String" sqlColumn="14" repeating="0">
  </Field>
  <Field name="TotalDeviseGlobal" required="0" datatype="%String" sqlColumn="15" repeating="0">
  </Field>
  <Field name="TotalEURGlobal" required="0" datatype="%String" sqlColumn="16" repeating="0">
  </Field>
  <Field name="TypeTableau" required="0" datatype="%String" sqlColumn="17" repeating="0">
  </Field>
</Record>
}

}

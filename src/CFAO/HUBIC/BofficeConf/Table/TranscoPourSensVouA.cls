Class CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA Extends %Persistent
{

Property NomBanque As %String(MAXLEN = 15) [ SqlColumnNumber = 2 ];

Property TypeOP As %String [ SqlColumnNumber = 3 ];

Property DeviseAchat As %String [ SqlColumnNumber = 4 ];

Property DeviseVente As %String [ SqlColumnNumber = 5 ];

Property Sens As %String(MAXLEN = 1) [ SqlColumnNumber = 6 ];

Property MontantDevise As %String [ SqlColumnNumber = 7 ];

Property DateCreation As %String(MAXLEN = 30) [ SqlColumnNumber = 8 ];

Property DateModif As %String(MAXLEN = 30) [ SqlColumnNumber = 9 ];

ClassMethod TouverLeSens(NomBanque As %String, TypeOP As %String, DeviseAchat As %String, DeviseVente As %String) As %Status
{
	
	Set SENSConf = ""	
	
	Set TraitementDevise = "USD"
	
	If DeviseVente = "EUR" Set TraitementDevise = "EUR"
	If DeviseAchat = "EUR" Set TraitementDevise = "EUR"
	
	If TraitementDevise = "EUR" {
		If DeviseAchat = "EUR" Set DeviseVente = "Autre devise"
		If DeviseVente = "EUR" Set DeviseAchat = "Autre devise"
	}Else{		
		If DeviseAchat = "USD" Set DeviseVente = "Autre devise"
		If DeviseVente = "USD" Set DeviseAchat = "Autre devise"
	}	
	
	&SQL(Select Sens INTO :SENSConf FROM CFAO_HUBIC_BofficeConf_Table.TranscoPourSensVouA 
			where NomBanque = :NomBanque AND TypeOP = :TypeOP AND DeviseAchat = :DeviseAchat AND DeviseVente = :DeviseVente)
			
	Quit SENSConf
}

Storage Default
{
<Data name="TranscoPourSensVouADefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>NomBanque</Value>
</Value>
<Value name="3">
<Value>TypeOP</Value>
</Value>
<Value name="4">
<Value>DeviseAchat</Value>
</Value>
<Value name="5">
<Value>DeviseVente</Value>
</Value>
<Value name="6">
<Value>Sens</Value>
</Value>
<Value name="7">
<Value>MontantDevise</Value>
</Value>
<Value name="8">
<Value>DateCreation</Value>
</Value>
<Value name="9">
<Value>DateModif</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBICF369.TranscoPour6751D</DataLocation>
<DefaultData>TranscoPourSensVouADefaultData</DefaultData>
<IdLocation>^CFAO.HUBICF369.TranscoPour6751D</IdLocation>
<IndexLocation>^CFAO.HUBICF369.TranscoPour6751I</IndexLocation>
<StreamLocation>^CFAO.HUBICF369.TranscoPour6751S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

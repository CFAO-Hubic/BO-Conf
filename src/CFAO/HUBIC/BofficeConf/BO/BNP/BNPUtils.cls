Class CFAO.HUBIC.BofficeConf.BO.BNP.BNPUtils Extends Ens.Rule.FunctionSet
{

/// Transforme le date au format :  30 mars 2016 au format 2016-04-30
ClassMethod FormatDateEmir(Date As %String)
{
		if (Date '= ""){
		Set JourDate = $piece(Date," ",2)
		Set MoisDate = $piece(Date," ",3)
		Set AnneeDate = $piece(Date," ",4)  
		//Jan Feb MAR APR MAY JUN JUL AUG SEP OCT NOV DEC
		If MoisDate = "janvier" Set MoisDate = "01"
		If MoisDate = "février" Set MoisDate = "02"
		If MoisDate = "mars" Set MoisDate = "03"
		If MoisDate = "avril" Set MoisDate = "04"
		If MoisDate = "mai" Set MoisDate = "05"
		If MoisDate = "juin" Set MoisDate = "06"
		If MoisDate = "juillet" Set MoisDate = "07"
		If MoisDate = "août" Set MoisDate = "08"
		If MoisDate = "aout" Set MoisDate = "08"
		If MoisDate = "septembre" Set MoisDate = "09"
		If MoisDate = "octobre" Set MoisDate = "10"
		If MoisDate = "novembre" Set MoisDate = "11"
		If MoisDate = "décembre" Set MoisDate = "12"	
		Set Date =  AnneeDate_"-"_MoisDate_"-"_JourDate
		Set Date = $Replace(Date," ","")	
	}
	
	return Date
}

ClassMethod SearchValue(pRequest As %Stream.FileCharacter, Filter As %String) As %String
{
	Set i = 0, LaLigne = ""
	While 'pRequest.AtEnd { 
		Set LaLigne = pRequest.ReadLine()	
		if $Find(LaLigne,Filter) > 0 {
			return LaLigne	 
		}
		Set i = i + 1   
	}
	return LaLigne
}

}

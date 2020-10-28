Class CFAO.HUBIC.Outils Extends Ens.Rule.FunctionSet
{

// ****************************************************************************************************************

// DEBUT Fonctions liées au flux CFAO vers le Stockiste PR                                                       *

// DEBUT Fonctions liées au flux CFAO vers le Stockiste PR                                                       *

// ****************************************************************************************************************

// ----------------------------------------------------------------------------

// Nombre de ligne de Entete type 1  - au moins une ligne doit etre presente

// ----------------------------------------------------------------------------

ClassMethod HchronoFourChar() As %String
{
	//set DateHeureFormatString = $PIECE($ZDATETIME($ZTIMESTAMP,8,1,3)," ",1)_$replace($PIECE($PIECE($ZDATETIME($ZTIMESTAMP,8,1,3)," ",2),".",1),":","")_$PIECE($PIECE($ZDATETIME($ZTIMESTAMP,8,1,3)," ",2),".",2)
	set DateHeureFormatString = ##class(CFAO.HUBIC.Outils).HCreateUniqueId()
	set ChronoFour = $ZHEX(DateHeureFormatString # 65535)
	$$$LOGINFO("ChronoFour :"_ ChronoFour)
	return ChronoFour
}

ClassMethod HCreateUniqueId(pDomain As %String = "") As %Integer
{
	if pDomain="" 
	{
		return $Increment(^COUNTER)
	} else {
		return $Increment(^COUNTER(pDomain))
	}
}

ClassMethod FromDateToJDE(dayofyear As %Integer, year As %Integer) As %Integer
{
	//Dayofyear repersente ici le nombre de jour ecoulé depuis le debut de l'année
	Quit (1000 * (year-1900)) + dayofyear
}

ClassMethod Padleft(Chaine As %String) As %String [ Language = basic ]
{
	Dim NbLigne
	set NbLigne = PadRight(Chaine,4,"0")
	return NbLigne
}

ClassMethod DiffDateVB(interval As %String, date1 As %String, date2 As %String) As %String [ Language = basic ]
{
	'Si Format date 1 =  JJ/MM/AAAA Format date 2 =  JJ/MM/AAAA
	'Si Format date 1 =  MM/JJ/AAAA Format date 2 =  MM/JJ/AAAA
	
	ret = DateDiff(interval, date1, date2)
	return ret
}

ClassMethod AddDateVB(interval As %String, number As %Integer, date1 As %String) As %String [ Language = basic ]
{
	'Ajouter ou enlever des jours a une date	
	dim retDate as string
	set retDate = DateAdd(interval,number,date1)		
	return retDate
}

ClassMethod skipZero(chaine As %String) As %String
{
	
		//initialisation des variable
	
	Set montant = chaine
	Set taille = $length(chaine) 
	set i = 1
	
	// $$$LOGINFO("chaine "_montant)
	// On boucle sur la chaine de caractére
	for var = 1:i:taille {
		
	 set value = $EXTRACT(montant,var)
	 	 
		if value '= 0 
		{		
		   	if $CHAR(value) = $CHAR(",")
		   	{
		   		set montant = "0"_$EXTRACT(montant,var,taille)
		   		//$$$LOGINFO("Tour : "_var_" valeur : "_value_" montant "_montant)
			}
			else{
				 set montant = $EXTRACT(montant,var,taille)
			}
		   		
			//$$$LOGINFO(espace_montant)						
			return montant
		}
	}
}

ClassMethod addBefore(chaine As %String, maxlenght As %Integer, CharBefore As %String) As %String
{
	//initialisation des variable
	
	Set montant = chaine
	Set taille = maxlenght-$length(chaine)
	set i = 1

	
	if taille > 0 {
		// On boucle sur la chaine de caractére
		for var = 1:i:taille {
			set montant = CharBefore_montant
			
		}
	}
	

	
	return montant
}

/// Converti une date au format Julien : format source est YYYYMMDD
ClassMethod GregorianDateToFormatJulien(date As %String) As %String
{
	set dateDuJour = $Extract(date,5,6)_"/"_$Extract(date,7,8)_"/"_$Extract(date,1,4)
	//$$$LOGINFO(dateDuJour)
	Set AnnéeEnCours = $Extract(date,1,4)
	set NbJourAnnee = ##Class(CFAO.HUBIC.Outils).DiffDateVB("d","01/01/"_AnnéeEnCours,dateDuJour) + 1
	//$$$LOGINFO("NbJourAnnee :"_NbJourAnnee)
	// Mise en forme au format Julien
	Set DateJourEnJulien = ##Class(CFAO.HUBIC.Outils).FromDateToJDE(NbJourAnnee,AnnéeEnCours)
	//$$$LOGINFO("DateJourEnJulien :"_DateJourEnJulien)
	return DateJourEnJulien
}

/// Converti une date au format Julien : DD/MM/YYYY
ClassMethod ConvertDateToFormatJulien(date As %String) As %String
{
	set dateDuJour = $piece(date,"/",2)_"/"_$piece(date,"/",1)_"/"_$piece(date,"/",3)
	//$$$LOGINFO(dateDuJour)
	Set AnnéeEnCours = $piece(date,"/",3)
	set NbJourAnnee = ##Class(CFAO.HUBIC.Outils).DiffDateVB("d","01/01/"_AnnéeEnCours,dateDuJour) + 1
	//$$$LOGINFO("NbJourAnnee :"_NbJourAnnee)
	// Mise en forme au format Julien
	Set DateJourEnJulien = ##Class(CFAO.HUBIC.Outils).FromDateToJDE(NbJourAnnee,AnnéeEnCours)
	//$$$LOGINFO("DateJourEnJulien :"_DateJourEnJulien)
	return DateJourEnJulien
}

/// Converti une date au format Julien : DD/MM/YYYY
ClassMethod ConvertDateToFormatJuliendsb(date As %String) As %String
{
	//set dateDuJour = $piece(date,"/",2)_"/"_$piece(date,"/",1)_"/"_$piece(date,"/",3)
	//$$$LOGINFO(dateDuJour)
	Set AnnéeEnCours = $piece(date,"/",3)
	set NbJourAnnee = ##Class(CFAO.HUBIC.Outils).DiffDateVB("d","01/01/"_AnnéeEnCours,date) + 1
	//$$$LOGINFO("NbJourAnnee :"_NbJourAnnee)
	// Mise en forme au format Julien
	Set DateJourEnJulien = ##Class(CFAO.HUBIC.Outils).FromDateToJDE(NbJourAnnee,AnnéeEnCours)
	//$$$LOGINFO("DateJourEnJulien :"_DateJourEnJulien)
	return DateJourEnJulien
}

ClassMethod RtrimHUBIC(Chaine As %String) As %String [ Language = basic ]
{
	Dim ChaineRtrim
	set ChaineRtrim = RTrim(Chaine)
	return ChaineRtrim
}

/// Arrondire un nombre a NbDecimal apres la virgule
ClassMethod RoundNumber(Number As %Integer, NbDecimal As %Integer) As %String [ Language = basic ]
{
	
	MyNumberRound = Round(Number,NbDecimal)
	MyNumberRound = Replace(MyNumberRound,".",",")
	return MyNumberRound
}

ClassMethod GetCurrentDateTime() As %String
{
	Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ"
	Set AnnéeSaisie = $extract(DateTraitement,1,4)
	Set MoisSaisie =  $extract(DateTraitement,5,6)
	Set jourSaisie =  $extract(DateTraitement,7,8)
	
	Set Htime=$PIECE($HOROLOG,",",2)
	Set ltime = $ZTIME(Htime,1)
	Set DateTraitTIMESTAMP =jourSaisie_"/"_MoisSaisie_"/"_ AnnéeSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
	
	return DateTraitTIMESTAMP
}

/// Methode d'envoi générique d'un mail (D.DIOP)
/// Utiliser par Back Office Confirmation
ClassMethod SendEmailGeneric(ServeurSMTP As %String, DestinataireMail As %String, DestinataireMailCopy As %String, ExpediteurMail As %String, ObjetMail As %String, ContenuDuMail As %Stream.GlobalCharacter, PieceJointeRepertoire As %String, PieceJointeNom As %String)
{
    // Create an SMTP object and connect to a server
    Set Mailer = ##class(%Net.SMTP).%New()

    // Fill in the name of your mail server //10.0.2.3
    Set Mailer.smtpserver = ServeurSMTP
   
    
	$$$LOGINFO("ServeurSMTP : "_ServeurSMTP)
    // Create a Message object and fill in From, To, Subject
    Set Msg = ##class(%Net.MailMessage).%New()
    Set Msg.From=ExpediteurMail    
    //Do Msg.To.Insert(DestinataireMail)    
    
    // Ajouter les destinataires Principale
	//Set DestinataireAlerte = DestinataireMail
   	SET delim=","
   	SET countdown = $LENGTH(DestinataireMail,delim)
   	SET countup = 1
   	FOR reps=countdown:-1:1 {
      	SET DestinataireUnParUn = $PIECE(DestinataireMail,delim,countup)
      	$$$LOGINFO("DestinataireUnParUn : "_DestinataireUnParUn)
      	do Msg.To.Insert(DestinataireUnParUn)	       	    
      	SET countup=countup+1
   	}    
     // Ajouter les destinataires En Copie
	//Set DestinataireAlerte = DestinataireMail
   	If $Replace(DestinataireMailCopy," ","") '= "" {
	   	SET delim=","
	   	SET countdownCopy = $LENGTH(DestinataireMailCopy,delim)
	   	SET countupCopy = 1
	   	FOR reps=countdownCopy:-1:1 {
	      	SET DestinataireUnParUnCopy = $PIECE(DestinataireMailCopy,delim,countupCopy)
	      	$$$LOGINFO("DestinataireUnParUnCopy : "_DestinataireUnParUnCopy)
	      	do Msg.Cc.Insert(DestinataireUnParUnCopy)	       	    
	      	SET countupCopy=countupCopy+1
	   	} 
   	}   
    
    Set Msg.Subject = ObjetMail	
	Set Msg.IsBinary=0
    Set Msg.IsHTML=0
    
    // Add message content
    While (ContenuDuMail.AtEnd = 0) {        
		do Msg.TextData.Write(ContenuDuMail.Read())  
	}
    
    If $Replace(PieceJointeRepertoire," ","") '= "" Do Msg.AttachFile(PieceJointeRepertoire,PieceJointeNom)
    
    // Send the message and close objects
    Set EnvoiMailer = Mailer.Send(Msg)
    $$$LOGINFO("EnvoiMailer : "_EnvoiMailer)
    Quit EnvoiMailer
}

// Transforme une datetime au format "display" (exemple DD/MM/YYYY) au format de datetime Intersystems (voir liste des formats ici: https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=RCOS_fzdate#RCOS_fzdate_dformat)

ClassMethod TransformStringDatetimeToDatetime(date2Transform As %String, dateFormat As %Integer, timeFormat As %Integer = 1) As %Date
{
	#dim theDate as %Date
	SET theDate =$zdatetimeh(date2Transform,15,1) // On transforme la date en horolog au format "européen"
	QUIT $ZDatetime(theDate,dateFormat,timeFormat) // On transforme l'horolog en format ODBC
}

// Transforme une datetime au format "display" (exemple DD/MM/YYYY) au format de date Intersystems (voir liste des formats ici: https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=RCOS_fzdate#RCOS_fzdate_dformat)

ClassMethod TransformStringDatetimeToDate(date2Transform As %String, dateFormat As %Integer) As %Date
{
	QUIT $PIECE(..TransformStringDatetimeToDatetime(date2Transform,dateFormat,1)," ",1)
}

// Transforme une date au format "display" (exemple DD/MM/YYYY) au format de date Intersystems (voir liste des formats ici: https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=RCOS_fzdate#RCOS_fzdate_dformat)

ClassMethod TransformStringDateToDatetime(date2Transform As %String, dateFormat As %Integer, timeFormat As %Integer = 1) As %Date
{
	if (date2Transform '=""){
		#dim theDate as %Date
		SET theDate =$zdateh(date2Transform,15,1) // On transforme la date en horolog au format "européen"
		QUIT $ZDatetime(theDate,dateFormat,timeFormat) // On transforme l'horolog en format ODBC
	}
	else { QUIT "" }
}

// Transforme une datetime au format "display" (exemple DD/MM/YYYY) au format de date Intersystems (voir liste des formats ici: https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=RCOS_fzdate#RCOS_fzdate_dformat)

ClassMethod TransformStringDateToDate(date2Transform As %String, dateFormat As %Integer) As %Date
{
	QUIT $PIECE(..TransformStringDateToDatetime(date2Transform,dateFormat,1)," ",1)
}

ClassMethod convertUnixTimeToUTCDatetime(sourceUnix As %Integer) As %String
{
	//Passage du timestamp UNIX au timestamp Caché (source https://matoski.com/article/unix-timestamp-in-intersystems-cache/) 
	//Ne fonctionne pas correctement: décale l'heure d'une heure... Case WRC# 924982 ouvert. La solution avec zdatetimeh (unix_timstamp, -2) semble fonctionne: à confirmer au passage à l'heure d'été
	//set timestampIS1 = ((sourceUnix\86400 + 47117)_","_(sourceUnix # 86400))
	
	//Passage du timestamp UNIX au timestamp Caché
	set timestampIS = $ZDATETIMEH(sourceUnix,-2)
	
	//Conversion du timestamp Caché au format UTC
	return $ZDATETIME(timestampIS,3)
}

/// Méthode de transformation d'une date au format Julien en format ODBC</br>
/// </br>
/// Pour rappel sur la date Julien:</br>
/// <li>Le 1er chiffre correspond au siècle: Il faut additioner 19 au premier chiffre pour avoir les 2 premiers chiffres de l'année</br>
/// <li>Les 2 chiffres suivants sont les 2 derniers chiffres de l'année</br>
/// <li>Les 3 derniers chiffres correspondent au nombre de jour depuis le 1er janvier de l'année.</br>
/// </br>
/// Le format de date de sortie: YYYY-MM-DD 00:00:00
ClassMethod convertDateJulienToDate(dateJulien As %String) As %String
{
	Set annee = ($EXTRACT(dateJulien)+19)_$EXTRACT(dateJulien,2,3)
	Set nbJours = $EXTRACT(dateJulien,*-2,*)
	
	Set euroDate = $SYSTEM.SQL.DATEADD("day",nbJours-1,$ZDATE($ZDATEH("01 01 "_annee,5),3))
	return $PIECE(euroDate, " ", 1)
}

/// Permet de supprimer les doublons dans une liste<br/>
/// <i>listeString</i>: La liste d'élément à dédoublonner de type String<br/>
/// <i>separator</i>: la chaîne de caractères qui sépare les éléments de la liste à dédoublonner
ClassMethod SupprimeDoublonsListe(listeString As %String, separator As %String) As %String
{
	//$$$LOGINFO("Liste à dédoublonner: "_listeString)
	set liste = $LISTFROMSTRING(listeString, separator)
	set ListeSansDoublon = ""
	//w $LISTLENGTH(liste),!
	For listIndex = 1:1:$LISTLENGTH(liste)
	{
		set item = $LISTGET(liste, listIndex)
		//w item,!
		if $LISTFIND(liste,item,listIndex) = 0 {
			//w "no doublon",!
			set ListeSansDoublon = item_","_ListeSansDoublon
		}
	}
	//w "Liste dédoublonnée: "_$EXTRACT(ListeSansDoublon,",",*-1),!
	//$$$LOGINFO("Liste dédoublonnée: "_$EXTRACT(ListeSansDoublon,",",*-1))
	return $EXTRACT(ListeSansDoublon,",",*-1)
}

/// Utilisée par CFAO.HUBIC.Newsletters.BS.ConnexionDominos
ClassMethod SupprimeCaractereSpeciauxDebut(ChaineDeCaractere As %String) As %String
{
	Set Chainemodifier = $Replace(ChaineDeCaractere,"","")
	Set Chainemodifier = $Replace(ChaineDeCaractere,"","")
	Set Chainemodifier = $Replace(ChaineDeCaractere,"","")
	Set Chainemodifier = $zstrip(Chainemodifier,"<P")
	Set Chainemodifier = $zstrip(Chainemodifier,"<C")
	
	return Chainemodifier
}

// ##class(CFAO.HUBIC.Outils).ZipFileBy7Zip("C:\Users\ahubicb\Desktop\","toto.txt","toto.zip","C:\Program Files\7-Zip\")

/// Cette classe permet d'archiver un fichier à l'aide de l'utilitaire 7Zip, qui est installé par défaut sur toutes nos machines.<br/>
/// Afin d'utiliser cette classe le fichier à archiver doit-être déposé dans un répertoire de travail: la classe créera alors un fichier archivé dans le même répertoire.<br/>
/// A noter aussi qu'un fichier <i>error.log</i> est généré dans ce répertoire en cas d'erreur lors de l'archivage.<br/><br/>
/// <i>workDirectory</i>: le chemin du répertoire de travail<br/>
/// <i>fileToZip</i>: le nom du fichier à archiver (avec son extension (ex: .txt))<br/>
/// <i>zippedFile</i>: le nom du fichier à créer (avec son extension (ex:.zip))<br/>
/// <i>path7Zip</i>: chemin vers le répertoire qui contient l'exécutable de 7zip
ClassMethod ZipFileBy7Zip(workDirectory As %String, fileToZip As %String, zippedFile As %String, path7Zip As %String) As %Status
{
    //set status=$zf(-100,"/SHELL /STDERR+="""_workDirectory_"\error.log""",path7Zip_"\7z.exe","a",workDirectory_pTargetFile,workDirectory_pSourceFile)
   	set status=$zf(-100,"/SHELL /STDERR+="""_workDirectory_"\error.log""",path7Zip_"\7z.exe","a",workDirectory_"\"_zippedFile,workDirectory_"\"_fileToZip)
    set status = 0
    if status=0 quit $$$OK
    quit $$$ERROR($$$GeneralError,"Failed to zip, reason code: "_status)
}

/// Méthode de suppression des espaces/tabulation à droite et à gauche d'une chaîne de caractères
ClassMethod Trim(ChaineDeCaractere As %String) As %String
{
	return $zstrip(ChaineDeCaractere,"<=>W")
}

/// Renvoie une ligne particulère d'un fichier, par numéro de ligne<br/>
/// Renvoie une ligne vide si le numéro de ligne est 0
/// <li>stream le fichier à lire
/// <li>number le numéro de ligne à récupérer
ClassMethod GetLineByNumber(stream As %Stream.Object, number As %Integer) As %String
{
	//set stream=##class(%Stream.FileCharacter).%New()
	//set sc=stream.LinkToFile("D:\HUBIC\Test\Test.txt")
	set line =""
	
	for i = 1:1:number
	{
		set line=stream.ReadLine(,.sc,.eol)
	}
	do stream.Rewind()
	return line
}

/// Convert date from DD Mmmm YYYY to specified format :
/// 1 : DD [separator] MM [separator] YYYY
/// 2 : MM [separator] DD [separator] YYYY
/// 3 : YYYY [separator] MM [separator] DD
/// 4 : DD [separator] MM [separator] YY
/// 5 : MM [separator] DD [separator] YY
ClassMethod convertDateDDMmmmYYYY(date As %String, resultSeparator As %String = "/", format As %Integer = 1, initialSeparator As %String = " ") As %String
{
    set day = $ZSTRIP($piece(date,initialSeparator,1), "*A")
    if $LENGTH(day) = 1 set day = "0"_day
	set month = $ZCONVERT($piece(date,initialSeparator,2), "l")
	set year = $piece(date,initialSeparator,3)

	set monthConvert = {
		"01": ["janvier", "january", "janv", "jan"],
		"02": ["février", "fevrier", "febuary", "feb", "fev", "fév"],
		"03": ["mars", "march", "mar"],
		"04": ["avril", "avr", "april", "apr"],
		"05": ["mai", "may"],
		"06": ["juin", "june"],
		"07": ["juillet", "juil", "july"],
		"08": ["août", "aout", "august", "aug"],
		"09": ["septembre", "september","sept", "sep"],
		"10": ["octobre","october","oct"],
		"11": ["novembre","november", "nov"],
		"12": ["décembre", "decembre","december","déc", "dec"]
	}

	set iter = monthConvert.%GetIterator()
	while iter.%GetNext(.key , .val) {
		set iter2 = val.%GetIterator()
		while iter2.%GetNext(.key2 , .val2) {
			set month = $REPLACE(month, val2, key)
		}
	}

    return $CASE(format,
	    1: day_resultSeparator_month_resultSeparator_year,
	    2: month_resultSeparator_day_resultSeparator_year,
	    3: year_resultSeparator_month_resultSeparator_day,
	    4: day_resultSeparator_month_resultSeparator_$EXTRACT(year, 3, 4),
	    5: month_resultSeparator_day_resultSeparator_$EXTRACT(year, 3, 4),
	     : ""
    )
}

ClassMethod queryJSON(request) As %Library.DynamicArray
{
	set query = ##class(%SQL.Statement).%New()
	set status = query.%Prepare(request)
	set result = query.%Execute()
	
	set metadata = result.%GetMetadata()
	set data = []

	while result.%Next() {
		set row = {}

		for j=1:1:metadata.columns.Count() {
			set $PROPERTY(row, metadata.columns.GetAt(j).colName) = result.%GetData(j)
		}

		do data.%Push(row)
	}

	return data
}

ClassMethod inArray(array, searched) As %Boolean
{
	set iter = array.%GetIterator()

	while iter.%GetNext(.key , .value ) {
		if value = searched return 1
	}

	return 0
}

}

xquery version "3.0";
module namespace common="http://www.insee.fr/collectes/commonstromae/common";

declare namespace functx = "http://www.functx.com";
declare namespace http="http://expath.org/ns/http-client";

(: JL - définition de la fonction common:parse-dateTime pour remplacer datetime:parse-dateTime qui ne marchera plus à partir d'eXist 5.0  :)

declare function common:parse-dateTime
  ($date as xs:string)  as xs:dateTime {
      let $year := substring($date,1,4) 
      let $month := substring($date,5,2) 
      let $day := substring($date,7,2) 
      let $hour := substring($date,9,2) 
      let $min := substring($date,11,2) 
      let $sec := substring($date,13,2) 

   return adjust-dateTime-to-timezone(dateTime(xs:date($year||'-'||$month||'-'||$day),
            xs:time($hour||':'||$min||':'||$sec)))
 } ;

declare function common:xql-response($entree as node()*) as node()* {
   let $rez := if ($entree//@status) then
   
            if ($entree//@status = ('404','200','201','202','203','204')) then 
                if ($entree[1]//http:response  and $entree[2]) then
                    (response:set-status-code($entree//@status),$entree[2])
                else if ($entree[1]//http:response  and not ($entree[2])) then
                    (response:set-status-code($entree//@status),$entree//@reason)
                else
                (response:set-status-code($entree//@status),$entree[1])
            else if ($entree//@reason) then 
                (response:set-status-code($entree//@status),$entree//@reason)    
                else (response:set-status-code($entree//@status))  
        else ($entree)
    return $rez           
           
};

declare function common:rest-response($status as xs:int*, $message as xs:string*) as node()* {
   let $niveauLog := if($status>=200 and $status <300)then "INFO" else "ERROR"
    let $log := util:log($niveauLog, concat("rest-response - $status : ", $status)) 
    let $restResponse := (: (response:set-status-code($status),<result>{$message}</result>) :)
            <rest:response>
               <http:response status="{$status}" reason="{$message}">
                   <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
               </http:response>
           </rest:response> 
           
           
    return $restResponse
};

(: fonction pour calculer le répertoire dans lequel est le questionnaire :)
declare function common:calcol ($arg as xs:string?) as xs:integer* {
    let $NOMBRE-COLLECTIONS := 30
    let $LETTRES := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    let $spli := functx:chars(translate($arg,$LETTRES,'0000000000000000000000000000000000000000000000000000'))
    let $tot := for $s in $spli return xs:integer($s)
    let $col := sum($tot) mod $NOMBRE-COLLECTIONS
    return $col
};

declare function functx:chars ($arg as xs:string?) as xs:string* {
    for $ch in string-to-codepoints($arg)
    return codepoints-to-string($ch)
};

(: Une fonction qui vérifie l'existence d'une collection à un emplacement donné et la crée si elle n'existe pas :)
declare function common:collection($emplacement as xs:string, $collection as xs:string) as xs:string{

let $test := if(not(xmldb:collection-available(concat($emplacement,'/',$collection))))
            then (xmldb:create-collection($emplacement, $collection))
            else ''
            return ''
};

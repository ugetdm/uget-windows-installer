; uGet - The #1 Open Source Download Manager.

; Copyright (C) 2018  uGetdm.com

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;--------------------------------
; Required Macros

!define StrRep "!insertmacro StrRep"
!macro StrRep output string old new
    Push `${string}`
    Push `${old}`
    Push `${new}`
    !ifdef __UNINSTALL__
        Call un.StrRep
    !else
        Call StrRep
    !endif
    Pop ${output}
!macroend

!macro Func_StrRep un
    Function ${un}StrRep
        Exch $R2 ;new
        Exch 1
        Exch $R1 ;old
        Exch 2
        Exch $R0 ;string
        Push $R3
        Push $R4
        Push $R5
        Push $R6
        Push $R7
        Push $R8
        Push $R9

        StrCpy $R3 0
        StrLen $R4 $R1
        StrLen $R6 $R0
        StrLen $R9 $R2
        loop:
            StrCpy $R5 $R0 $R4 $R3
            StrCmp $R5 $R1 found
            StrCmp $R3 $R6 done
            IntOp $R3 $R3 + 1 ;move offset by 1 to check the next character
            Goto loop
        found:
            StrCpy $R5 $R0 $R3
            IntOp $R8 $R3 + $R4
            StrCpy $R7 $R0 "" $R8
            StrCpy $R0 $R5$R2$R7
            StrLen $R6 $R0
            IntOp $R3 $R3 + $R9 ;move offset by length of the replacement string
            Goto loop
        done:

        Pop $R9
        Pop $R8
        Pop $R7
        Pop $R6
        Pop $R5
        Pop $R4
        Pop $R3
        Push $R0
        Push $R1
        Pop $R0
        Pop $R1
        Pop $R0
        Pop $R2
        Exch $R1
    FunctionEnd
!macroend
!insertmacro Func_StrRep ""
; !insertmacro Func_StrRep "un."

; ################################################################
; appends \ to the path if missing
; example: !insertmacro GetCleanDir "c:\blabla"
; Pop $0 => "c:\blabla\"
!macro GetCleanDir INPUTDIR
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_GetCleanDir 'GetCleanDir_Line${__LINE__}'
  Push $R0
  Push $R1
  StrCpy $R0 "${INPUTDIR}"
  StrCmp $R0 "" ${Index_GetCleanDir}-finish
  StrCpy $R1 "$R0" "" -1
  StrCmp "$R1" "\" ${Index_GetCleanDir}-finish
  StrCpy $R0 "$R0\"
${Index_GetCleanDir}-finish:
  Pop $R1
  Exch $R0
  !undef Index_GetCleanDir
!macroend
 
; ################################################################
; similar to "RMDIR /r DIRECTORY", but does not remove DIRECTORY itself
; example: !insertmacro RemoveFilesAndSubDirs "$INSTDIR"
!macro RemoveFilesAndSubDirs DIRECTORY
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_RemoveFilesAndSubDirs 'RemoveFilesAndSubDirs_${__LINE__}'
 
  Push $R0
  Push $R1
  Push $R2
 
  !insertmacro GetCleanDir "${DIRECTORY}"
  Pop $R2
  FindFirst $R0 $R1 "$R2*.*"
${Index_RemoveFilesAndSubDirs}-loop:
  StrCmp $R1 "" ${Index_RemoveFilesAndSubDirs}-done
  StrCmp $R1 "." ${Index_RemoveFilesAndSubDirs}-next
  StrCmp $R1 ".." ${Index_RemoveFilesAndSubDirs}-next
  IfFileExists "$R2$R1\*.*" ${Index_RemoveFilesAndSubDirs}-directory
  ; file
  Delete "$R2$R1"
  goto ${Index_RemoveFilesAndSubDirs}-next
${Index_RemoveFilesAndSubDirs}-directory:
  ; directory
  RMDir /r "$R2$R1"
${Index_RemoveFilesAndSubDirs}-next:
  FindNext $R0 $R1
  Goto ${Index_RemoveFilesAndSubDirs}-loop
${Index_RemoveFilesAndSubDirs}-done:
  FindClose $R0
 
  Pop $R2
  Pop $R1
  Pop $R0
  !undef Index_RemoveFilesAndSubDirs
!macroend

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General
  !define _APPLICATION_NAME "uGet"
  !define _VERSION "2.2.0"
  !define _RELEASE "0"
  !define _COMPANY "uGetdm.com"
  !define _DESCRIPTION "#1 Open Source Download Manager"

  ;Name and file
  Name "${_APPLICATION_NAME}"
  OutFile "${_APPLICATION_NAME}-${_VERSION}-win32+gtk3.exe"

  ;Default installation folder
  InstallDir $PROGRAMFILES\${_APPLICATION_NAME}

  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${_APPLICATION_NAME}" "Install_Dir"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "resource\license"
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Version Information
  VIProductVersion "${_VERSION}.${_RELEASE}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${_APPLICATION_NAME}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${_VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "${_DESCRIPTION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${_COMPANY}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright 2018 ${_COMPANY}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${_APPLICATION_NAME} Installer"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${_VERSION}.${_RELEASE}"
  
;--------------------------------
; The stuff to install
Section "uGet (required)"

	SectionIn RO

	; Set output path to the installation directory.
	SetOutPath $INSTDIR

	; Put the files
	File /r "uget-${_VERSION}-win32+gtk3\*.*"

	; Replace \ by \\ in the installation path
	${StrRep} $0 "$INSTDIR" "\" "\\"
	
	
	; Put the icon
	File "resource\icon.ico"
	
  ; Create Start Menu launcher
	createShortCut "$SMPROGRAMS\${_APPLICATION_NAME}.lnk" "$INSTDIR\bin\uget.exe" "" "$INSTDIR\icon.ico"

	; Write the installation path into the registry
	WriteRegStr HKLM "SOFTWARE\${_APPLICATION_NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\uget.exe" "" "$INSTDIR\bin\uget.exe"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\uget.exe" "Path" "$INSTDIR\bin;"


	; Write the uninstall keys for Windows
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "DisplayName" "${_APPLICATION_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "Publisher" "${_COMPANY}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "HelpLink" "http://www.ugetdm.com/help"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "URLUpdateInfo" "http://www.ugetdm.com/downloads"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "URLInfoAbout" "http://www.ugetdm.com/about"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "DisplayVersion" "${_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "DisplayIcon" "$INSTDIR\icon.ico,0"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" "NoRepair" 1
	WriteUninstaller "uninstall.exe"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  # Remove Start Menu launcher
	Delete "$SMPROGRAMS\${_APPLICATION_NAME}.lnk"

	; Remove registry keys
	DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\uget.exe"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}"
	DeleteRegKey HKLM "SOFTWARE\${_APPLICATION_NAME}"

	; Remove files and uninstaller
 	!insertmacro RemoveFilesAndSubDirs "$INSTDIR\"

	; Remove directories used
	RMDir "$INSTDIR"

SectionEnd


;--------------------------------
; uninstall the previous version
Function .onInit
 
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_APPLICATION_NAME}" \
  "UninstallString"
  StrCmp $R0 "" done
 
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${_APPLICATION_NAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  Exec $R0
done:
 
FunctionEnd
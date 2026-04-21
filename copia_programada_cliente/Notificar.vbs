' Notificar.vbs
' Muestra una notificacion popup en Windows
' Recibe tres argumentos: titulo, mensaje y segundos
' Uso: cscript.exe Notificar.vbs "Backup" "Copia realizada" 5

Set objArgs = WScript.Arguments
If objArgs.Count < 2 Then
    WScript.Quit
End If

titulo = objArgs(0)
mensaje = objArgs(1)
tipoMensaje = "ok"

If objArgs.Count >= 3 Then
    tipoMensaje = LCase(objArgs(2))
End If

If tipoMensaje = "error" Then
	icono = 16
Else
	icono = 64
End If

Set objShell = CreateObject("WScript.Shell")
' Parametro 64 = icono de informacion
objShell.Popup mensaje, 0, titulo, icono

---
title: Могущественная скорлупа
date: 2014-10-23 12:13 MSK
tags:
- powershell
---

Могущественная скорлупа — это, конечно же, шуточный перевод
[PowerShell](http://en.wikipedia.org/wiki/Windows_PowerShell). Обратиться к этой теме старого любителя Linux заставило
не праздное любопытство, а насущная производственная необходимость. Конечно же, в мире Linux принято весело хохотать и
поливать грязью все, что относится к Windows. Но, надо сказать, что многое изменилось в мире Windows, за последнее
время.

Во-первых, появился аналог ssh. По протоколу WinRM с помощью PowerShell можно ходить по другим машинкам не хуже, чем по
ssh.

```
PS C:\> Enter-PSSession dc
[dc]: PS C:\Users\Administrator\Documents>
```

Во-вторых, появилась возможность управлять почти всеми кишками винды с помощью могущественной скорлупы, тьфу,
powershell. Например, вот так выглядит аналог `ps aux | grep snmp`.

```
Get-Process | ? { $_.Name -like 'snmp' }
```

Конечно, выглядит достаточно многословно, но для большинства команд есть короткие алиасы, посмотреть которые можно с
помощью `Get-Alias`. Вы будете удивлены, но многие алиасы пришли из мира Linux, например, тот же `Get-Process`
сокращается до привычного `ps`.

Более того, в PowerShell есть привычная концепция пайпов (pipe), только вместо текстовых строк по пайпам бегают реальные
объекты. Мне лично кажется, что это шаг вперед. Не надо воротить команды с `awk` и `cut`, и всегда можно посмотреть
метаданные того, что пришло тебе через пайп.

```
ps | Get-Member


   TypeName: System.Diagnostics.Process

Name                       MemberType     Definition
----                       ----------     ----------
Handles                    AliasProperty  Handles = Handlecount
Name                       AliasProperty  Name = ProcessName
NPM                        AliasProperty  NPM = NonpagedSystemMemorySize
PM                         AliasProperty  PM = PagedMemorySize
VM                         AliasProperty  VM = VirtualMemorySize
WS                         AliasProperty  WS = WorkingSet
Disposed                   Event          System.EventHandler Disposed(System.Object, System.EventArgs)
...
```

Плюс к тому, если ничего не помогает, можно всегда создать .Net класс прямо из PowerShell и воротить, вообще, что
угодно. Например, преобразовывать xml файлы.

```powershell
$Xml = New-Object System.Xml.XmlDocument
$Xml.Load($XmlFile)
$Xml.SelectSingleNode("/my/xpath").InnerXml = "<justforfun />"
$Xml.Save($XmlFile)
```

С появлением в Windows headless режима, эта ОС все меньше похожа на игрушку, где надо тыкать мышкой по кнопочкам.

Я, конечно, считаю, что PowerShell уступает в изяществе Ruby, но могущественность его от этого нисколько не страдает.

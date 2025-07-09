# Define o caminho da pasta pr�-determinada
$pasta = 

# Inicia o loop de pesquisa
while ($true) {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host " Base de Conhecimento " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan

    # Obt�m todos os arquivos PDF da pasta e subpastas
    $arquivosPDF = Get-ChildItem -Path $pasta -Recurse -File -Filter *.pdf

    # Inicializa as vari�veis de controle
    $termoDeBusca = ""
    $tentativasInvalidas = 0

    # Solicita ao usu�rio que digite parte do nome do arquivo para abrir
    $termoDeBusca = Read-Host "`nDigite parte do nome do arquivo PDF que deseja abrir (ou 's' para encerrar, ou 'T' para mostrar todos)"

    # Verifica se o usu�rio quer encerrar o script
    if ($termoDeBusca -eq 's') {
        Write-Host "`nEncerrando a pesquisa. At� a pr�xima!" -ForegroundColor Green
        Start-Sleep -Seconds 2
        break
    }

    # Verifica se o usu�rio quer ver todos os arquivos
    if ($termoDeBusca -eq 'T') {
        $arquivosFiltrados = $arquivosPDF
    } else {
        # Verifica se o campo de busca est� vazio
        if ([string]::IsNullOrWhiteSpace($termoDeBusca)) {
            Write-Host "`nVoc� precisa digitar algo para buscar um arquivo." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        }

        # Verifica se o termo de busca � apenas "pdf" ou ".pdf"
        if ($termoDeBusca -match '^(?i)\.?pdf$') {
            Write-Host "`nDocumento n�o localizado" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        }

        # Divide o termo de busca em palavras-chave (removendo espa�os extras)
        $palavrasChave = $termoDeBusca -split "\s+" | Where-Object { $_ -ne "" }

        # Filtra os arquivos PDF para que contenham todas as palavras-chave como palavra inteira (busca case-insensitive)
        $arquivosFiltrados = $arquivosPDF | Where-Object {
            $nomeArquivo = $_.Name
            $todasPresentes = $true
            foreach ($palavra in $palavrasChave) {
                # Adiciona \b antes e depois para procurar a palavra inteira
                $regex = "(?i)\b$([regex]::Escape($palavra))\b"
                if (-not ($nomeArquivo -match $regex)) {
                    $todasPresentes = $false
                    break
                }
            }
            $todasPresentes
        }
    }

    # Se a busca foi por "T", n�o aplica a limita��o de 10 documentos
    if ($termoDeBusca -ne 'T' -and $arquivosFiltrados.Count -gt 10) {
        Write-Host "`nForam encontrados mais de 10 documentos." -ForegroundColor Yellow
        Start-Sleep -Seconds 2

        # Pergunta ao usu�rio se deseja refinar a busca
        $refinarBusca = Read-Host "`nDeseja refinar a busca (S/N)"

        if ($refinarBusca -eq 's') {
    # Se escolher "S", pede um novo termo sem reiniciar o loop
    $novoTermoDeBusca = Read-Host "`nDigite o novo termo de busca"
    $novoTermoDeBusca = $novoTermoDeBusca.Trim()  # Remove espa�os no in�cio e no final
    
    # Verifica se o novo termo � uma string v�lida
    if (-not [string]::IsNullOrEmpty($novoTermoDeBusca)) {
        # Verifica se o novo termo � o mesmo que o anterior
        if ($novoTermoDeBusca -eq $termoDeBusca) {
            Write-Host "`nVoc� digitou o mesmo termo de busca. Exibindo novamente mais de 10 documentos" -ForegroundColor Yellow
            
            # Mensagem para pedir mais detalhes e capturar um novo termo
            $novoTermoDeBusca = Read-Host "`nDe mais detalhes"
            $novoTermoDeBusca = $novoTermoDeBusca.Trim()  # Remove espa�os no in�cio e no final

            # Verifica se o termo de busca n�o � vazio depois de usar Trim()
            if ([string]::IsNullOrEmpty($novoTermoDeBusca)) {
                Write-Host "`nO termo de busca n�o pode estar vazio!" -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue  # Pede ao usu�rio para digitar um termo v�lido
            } else {
                # Atualiza o termo de busca com o novo valor
                $termoDeBusca = $novoTermoDeBusca
                $palavrasChave = $termoDeBusca -split "\s+" | Where-Object { $_ -ne "" }
            }
        } else {
            # Se o termo for diferente, refaz a busca com o novo termo
            $termoDeBusca = $novoTermoDeBusca  # Atualiza o termo de busca
            $palavrasChave = $termoDeBusca -split "\s+" | Where-Object { $_ -ne "" }
        }
        
        # Refaz a busca com o termo atualizado
        $arquivosFiltrados = $arquivosPDF | Where-Object {
            $nomeArquivo = $_.Name
            $todasPresentes = $true
            foreach ($palavra in $palavrasChave) {
                $regex = "(?i)\b$([regex]::Escape($palavra))\b"
                if (-not ($nomeArquivo -match $regex)) {
                    $todasPresentes = $false
                    break
                }
            }
            $todasPresentes
        }
        
        $tentativasInvalidas = 0  # Reseta as tentativas inv�lidas
    } else {
        Write-Host "`nO termo de busca n�o pode estar vazio!" -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue  # Pede ao usu�rio para digitar um termo v�lido
    }
} else {
    # Se escolher "N", cancela a opera��o e reinicia o loop
    Write-Host "`nOpera��o cancelada." -ForegroundColor Yellow
    $termoDeBusca = ""  # Reseta o termo de busca
    $tentativasInvalidas = 0  # Reseta as tentativas inv�lidas
    Start-Sleep -Seconds 2
    continue
}


    }

    # Exibe os arquivos filtrados e permite que o usu�rio selecione um para abrir
    if ($arquivosFiltrados) {
        Write-Host "`nArquivos encontrados:" -ForegroundColor Green
        Write-Host "----------------------------------------" -ForegroundColor DarkGray

        # Enumera os arquivos encontrados
        $arquivosFiltrados | ForEach-Object {
            $i = [array]::IndexOf($arquivosFiltrados, $_) + 1
            $nomeSemExtensao = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

            # Verifica se o nome do arquivo cont�m a palavra "OLD"
            if ($nomeSemExtensao -match 'OLD') {
                $corTexto = 'Red'
                $avisoOLD = " (N�O UTILIZAR)"
            }
            else {
                $corTexto = 'White'
                $avisoOLD = ""
            }

            # Se o usu�rio digitou "T" para mostrar todos, n�o aplica o destaque
            if ($termoDeBusca -eq 'T') {
                Write-Host "$i. $nomeSemExtensao$avisoOLD" -ForegroundColor $corTexto
            }
            else {
                # Exibe o n�mero do arquivo sem quebra de linha
                Write-Host -NoNewline "$i. "
                # Constr�i o pattern unificando todas as palavras-chave pesquisadas
                $pattern = ($palavrasChave | ForEach-Object { [regex]::Escape($_) }) -join '|'
                $nomeDestacado = $nomeSemExtensao
                # Busca todas as ocorr�ncias (usando \b para delimitar palavras e (?i) para case-insensitive)
                $matches = [regex]::Matches($nomeDestacado, "(?i)\b($pattern)\b")
                $lastIndex = 0
                foreach ($match in $matches) {
                    $start = $match.Index
                    $length = $match.Length
                    # Exibe o trecho antes da ocorr�ncia encontrada
                    $textoAntes = $nomeDestacado.Substring($lastIndex, $start - $lastIndex)
                    Write-Host -NoNewline $textoAntes -ForegroundColor $corTexto
                    # Exibe a palavra encontrada destacada
                    Write-Host -NoNewline $match.Value -ForegroundColor Magenta
                    $lastIndex = $start + $length
                }
                # Exibe o que sobra ap�s a �ltima ocorr�ncia, se houver
                if ($lastIndex -lt $nomeDestacado.Length) {
                    Write-Host -NoNewline $nomeDestacado.Substring($lastIndex) -ForegroundColor $corTexto
                }
                Write-Host $avisoOLD -ForegroundColor $corTexto
            }
        }

        Write-Host "----------------------------------------" -ForegroundColor DarkGray

        # Inicializa o contador de erros
        $tentativasInvalidas = 0

        # Solicita ao usu�rio para selecionar o n�mero do arquivo
        while ($true) {
            $indiceSelecionado = Read-Host "`nDigite o n�mero do arquivo PDF que deseja abrir (ou pressione Enter para uma nova busca)"

            # Se o usu�rio pressionou Enter (sem digitar n�mero), continua a busca
            if (-not $indiceSelecionado) {
                break
            }

            # Verifica se o valor � um n�mero v�lido e dentro do intervalo
            if ($indiceSelecionado -match '^\d+$' -and $indiceSelecionado -ge 1 -and $indiceSelecionado -le $arquivosFiltrados.Count) {
                $indiceSelecionado = [int]$indiceSelecionado
                $arquivoSelecionado = $arquivosFiltrados[$indiceSelecionado - 1].FullName
                $nomeArquivoSelecionado = [System.IO.Path]::GetFileNameWithoutExtension($arquivosFiltrados[$indiceSelecionado - 1].Name)

                # Se for um documento "OLD", confirma se deseja abrir
                if ($nomeArquivoSelecionado -match 'OLD') {
                    $confirmacao = Read-Host "`nATEN��O: Este documento � marcado como 'OLD' e N�O deve ser utilizado. Deseja abrir assim mesmo? (s/n)"
                    if ($confirmacao -ne 's') {
                        Write-Host "`nOpera��o cancelada." -ForegroundColor Yellow
                        # Limpa os campos e reinicia a busca
                        $termoDeBusca = ""
                        $tentativasInvalidas = 0
                        Start-Sleep -Seconds 2
                        break
                    }
                }

                Write-Host "`nAbrindo o arquivo: $($arquivosFiltrados[$indiceSelecionado - 1].Name)" -ForegroundColor Yellow
                Start-Process -FilePath $arquivoSelecionado
                break
            }
            else {
                $tentativasInvalidas++
                Write-Host "`nOp��o inv�lida. Por favor, insira um n�mero v�lido de 1 at� $($arquivosFiltrados.Count)." -ForegroundColor Red

                # Se ocorrer 3 tentativas inv�lidas, reinicia a busca
                if ($tentativasInvalidas -ge 3) {
                    Write-Host "`nVoc� cometeu 3 erros consecutivos. Reiniciando a busca..." -ForegroundColor Magenta
                    $termoDeBusca = ""
                    $tentativasInvalidas = 0
                    Start-Sleep -Seconds 2
                    break
                }
            }
        }
    } else {
        Write-Host "`nNenhum arquivo encontrado com o termo de busca informado." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

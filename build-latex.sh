#!/bin/bash
# =============================================================================
# Script de compilação LaTeX com abnTeX2
# Uso: ./build-latex.sh [clean]
#   - Sem argumentos: compila o projeto (pdflatex + bibtex + pdflatex x2)
#   - Com "clean": apenas remove os arquivos temporários
# =============================================================================

TEX_FILE="main"

# Cores para o terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

# Função para limpar arquivos temporários
limpar() {
    echo -e "${YELLOW}Removendo arquivos temporários...${NC}"
    rm -f "${TEX_FILE}".{aux,bbl,blg,brf,idx,ilg,ind,lof,log,loq,lot,out,toc,fls,fdb_latexmk,synctex.gz,run.xml,bcf}
    echo -e "${GREEN}Arquivos temporários removidos.${NC}"
}

# Se o argumento for "clean", apenas limpa e sai
if [ "$1" = "clean" ]; then
    limpar
    exit 0
fi

echo -e "${YELLOW}=== Compilando ${TEX_FILE}.tex ===${NC}"

# Passo 1: pdflatex (primeira passada)
echo -e "${YELLOW}[1/4] pdflatex (primeira passada)...${NC}"
pdflatex -interaction=nonstopmode "${TEX_FILE}.tex" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}ERRO na primeira passada do pdflatex. Verifique o arquivo ${TEX_FILE}.log${NC}"
    exit 1
fi

# Passo 2: bibtex (referências bibliográficas)
echo -e "${YELLOW}[2/4] bibtex...${NC}"
bibtex "${TEX_FILE}" > /dev/null 2>&1

# Passo 3: pdflatex (segunda passada - resolver referências)
echo -e "${YELLOW}[3/4] pdflatex (segunda passada)...${NC}"
pdflatex -interaction=nonstopmode "${TEX_FILE}.tex" > /dev/null 2>&1

# Passo 4: pdflatex (terceira passada - referências cruzadas)
echo -e "${YELLOW}[4/4] pdflatex (terceira passada)...${NC}"
pdflatex -interaction=nonstopmode "${TEX_FILE}.tex" > /dev/null 2>&1

# Limpar arquivos temporários
limpar

# Verificar se o PDF foi gerado
if [ -f "${TEX_FILE}.pdf" ]; then
    TAMANHO=$(du -h "${TEX_FILE}.pdf" | cut -f1)
    PAGINAS=$(pdfinfo "${TEX_FILE}.pdf" 2>/dev/null | grep "Pages" | awk '{print $2}')
    echo -e "${GREEN}=== Compilação concluída com sucesso! ===${NC}"
    echo -e "${GREEN}PDF: ${TEX_FILE}.pdf (${TAMANHO}, ${PAGINAS:-?} páginas)${NC}"
else
    echo -e "${RED}ERRO: PDF não foi gerado.${NC}"
    exit 1
fi

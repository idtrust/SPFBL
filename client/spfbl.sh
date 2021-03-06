#!/bin/bash
#
# This file is part of SPFBL.
# and open the template in the editor.
#
# SPFBL is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SPFBL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SPFBL.  If not, see <http://www.gnu.org/licenses/>.
#
# Projeto SPFBL - Copyright Leandro Carlos Rodrigues - leandro@spfbl.net
# https://github.com/leonamp/SPFBL
#
# Atenção! Para utilizar este serviço, solicite a liberação das consultas
# no servidor matrix.spfbl.net através do endereço leandro@spfbl.net
# ou altere o matrix.spfbl.net deste script para seu servidor SPFBL próprio.
# 
# Atenção! Para utilizar este script é necessário ter o netcat instalado:
#
#   sudo apt-get install netcat
#
# Se estiver usando a autenticação por OTP, prencha a constante OTP_SECRET
# com a chave secreta fornecida pelo serviço SPFBL e mantenha a variável 
# OTP_SECRET vazia. É necessário oathtool para usar esta autenticação:
#
#   sudo apt-get install oathtool
#

### CONFIGURACOES ###
IP_SERVIDOR="matrix.spfbl.net"
PORTA_SERVIDOR="9877"
PORTA_ADMIN="9875"
OTP_SECRET=""
DUMP_PATH="/tmp"
QUERY_TIMEOUT="10"

export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
version="2.4"

head()
{
	echo "SPFBL v$version - by Leandro Rodrigues - leandro@spfbl.net"
}

if [[ $OTP_SECRET == "" ]]; then
	OTP_CODE=""
else
	OTP_CODE="$(oathtool --totp -b -d 6 $OTP_SECRET) "
fi

case $1 in
	'version')
		# Verifica a versão do servidor SPPFBL.
		#
		# Códigos de saída:
		#
		#    0: versão adquirida com sucesso.
		#    1: erro ao tentar adiquirir versão.
		#    2: timeout de conexão.


		response=$(echo $OTP_CODE"VERSION" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

		if [[ $response == "" ]]; then
			response="TIMEOUT"
		fi

		echo "$response"
	;;
	'firewall')
		# Constroi um firewall pelo SPPFBL.
		#
		# Códigos de saída:
		#
		#    0: firwall adquirido com sucesso.
		#    1: erro ao tentar adiquirir firewall.
		#    2: timeout de conexão.


		response=$(echo $OTP_CODE"FIREWALL" | nc $IP_SERVIDOR $PORTA_ADMIN)

		if [[ $response == "" ]]; then
			response="TIMEOUT"
		fi

		echo "$response"

		if [[ $response == "TIMEOUT" ]]; then
			exit 2
		elif [[ $response == "#!/bin/bash"* ]]; then
			exit 0
		else
			exit 1
		fi
	;;
	'shutdown')
		# Finaliza Serviço.
		#
		# Códigos de saída:
		#
		#    0: fechamento de processos realizado com sucesso.
		#    1: houve falha no fechamento dos processos.
		#    2: timeout de conexão.


		response=$(echo $OTP_CODE"SHUTDOWN" | nc $IP_SERVIDOR $PORTA_ADMIN)

		if [[ $response == "" ]]; then
			response="TIMEOUT"
		fi

		echo "$response"
	;;
	'store')
		# Comando para gravar o cache em disco.
		#
		# Códigos de saída:
		#
		#    0: gravar o cache em disco realizado com sucesso.
		#    1: houve falha ao gravar o cache em disco.
		#    2: timeout de conexão.


		response=$(echo $OTP_CODE"STORE" | nc $IP_SERVIDOR $PORTA_ADMIN)

		if [[ $response == "" ]]; then
			response="TIMEOUT"
		fi

		echo "$response"
	;;
	'tld')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. tld: endereço do tld.
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 tld add tld\n"
				else
					tld=$3

					response=$(echo $OTP_CODE"TLD ADD $tld" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. tld: endereço do tld.
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 tld drop tld\n"
				else
					tld=$3

					response=$(echo $OTP_CODE"TLD DROP $tld" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')

				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 tld show\n"
				else

					response=$(echo $OTP_CODE"TLD SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 tld add tld\n    $0 tld drop tld\n    $0 tld show\n"
			;;
		esac
	;;
	'provider')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. provedor: endereço do provedor de e-mail.
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 provider add sender\n"
				else
					provider=$3

					response=$(echo $OTP_CODE"PROVIDER ADD $provider" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. provedor: endereço do provedor de e-mail.
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 provider drop sender\n"
				else
					provider=$3

					response=$(echo $OTP_CODE"PROVIDER DROP $provider" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')

				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 provider show\n"
				else

					response=$(echo $OTP_CODE"PROVIDER SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 provider add sender\n    $0 provider drop sender\n    $0 provider show\n"
			;;
		esac
	;;
	'ignore')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser ignorado, com endereço completo.
				#    1. domínio: o domínio que deve ser ignorado, com arroba (ex: @dominio.com.br)
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 ignore add sender\n"
				else
					ignore=$3

					response=$(echo $OTP_CODE"IGNORE ADD $ignore" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente ignorado, com endereço completo.
				#    1. domínio: o domínio ignorado, com arroba (ex: @dominio.com.br)
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 ignore drop sender\n"
				else
					ignore=$3

					response=$(echo $OTP_CODE"IGNORE DROP $ignore" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')

				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 ignore show\n"
				else

					response=$(echo $OTP_CODE"IGNORE SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 ignore add sender\n    $0 ignore drop sender\n    $0 ignore show\n"
			;;
		esac
	;;
	'block')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser bloqueado, com endereço completo.
				#    1. domínio: o domínio que deve ser bloqueado, com arroba (ex: @dominio.com.br)
				#    1. caixa postal: a caixa postal que deve ser bloqueada, com arroba (ex: www-data@)
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 block add sender\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK ADD $sender" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser desbloqueado, com endereço completo.
				#    1. domínio: o domínio que deve ser desbloqueado, com arroba (ex: @dominio.com.br)
				#    1. caixa postal: a caixa postal que deve ser desbloqueada, com arroba (ex: www-data@)
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 block drop sender\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK DROP $sender" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada:
				#    1: ALL: lista os bloqueios gerais (opcional)
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 block show [all]\n"
				else
					if [ "$3" == "all" ]; then
						response=$(echo $OTP_CODE"BLOCK SHOW ALL" | nc $IP_SERVIDOR $PORTA_SERVIDOR)
					else
						response=$(echo $OTP_CODE"BLOCK SHOW" | nc $IP_SERVIDOR $PORTA_SERVIDOR)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'find')
				# Parâmetros de entrada:
				#    1: <token>: um e-mail, host ou IP.
				#
				# Códigos de saída:
				#
				#    0: sem registro.
				#    1: registro encontrado.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 block find token\n"
				else
 					token=$3
					response=$(echo $OTP_CODE"BLOCK FIND $token" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 block add recipient\n    $0 block drop recipient\n    $0 block show\n"
			;;
		esac
	;;
	'superblock')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser bloqueado, com endereço completo.
				#    1. domínio: o domínio que deve ser bloqueado, com arroba (ex: @dominio.com.br)
				#    1. caixa postal: a caixa postal que deve ser bloqueada, com arroba (ex: www-data@)
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock add sender\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK ADD $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'split')
				# Parâmetros de entrada:
				#
				#    1. cidr: o bloco que deve ser utilizado.
				#
				# Códigos de saída:
				#
				#    Nenhum: Observar o retorno do servidor.
				#

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock split CIDR\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK SPLIT $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'overlap')
				# Parâmetros de entrada:
				#
				#    1. cidr: o bloco que deve ser utilizado.
				#
				# Códigos de saída:
				#
				#    Nenhum: Observar o retorno do servidor.
				#
				

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock overlap CIDR\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK OVERLAP $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'extract')
				# Parâmetros de entrada:
				#
				#    1. cidr: o bloco que deve ser utilizado.
				#
				# Códigos de saída:
				#
				#    Nenhum: Observar o retorno do servidor.
				#
				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock extract IP\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK EXTRACT $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser desbloqueado, com endereço completo.
				#    1. domínio: o domínio que deve ser desbloqueado, com arroba (ex: @dominio.com.br)
				#    1. caixa postal: a caixa postal que deve ser desbloqueada, com arroba (ex: www-data@)
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock drop sender\n"
				else
					sender=$3

					response=$(echo $OTP_CODE"BLOCK DROP $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada:
				#    1: ALL: lista os bloqueios gerais (opcional)
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superblock show [all]\n"
				else
					if [ "$3" == "all" ]; then
						response=$(echo $OTP_CODE"BLOCK SHOW ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"BLOCK SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 superblock add recipient\n    $0 superblock drop recipient\n    $0 superblock split cidr\n    $0 superblock overlap cidr\n    $0 superblock extract cidr\n    $0 superblock show\n"
			;;
		esac
	;;
	'generic')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar generico.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Faltando parametro(s).\nSintaxe: $0 generic add sender\n"
				else
					sender=$3

					response=$(echo "GENERIC ADD $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"

					if [[ $response == "TIMEOUT" ]]; then
						exit 2
					elif [[ $response == "ADDED" ]]; then
						exit 0
					else
						exit 1
					fi
				fi
			;;
			'find')
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar generico.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Faltando parametro(s).\nSintaxe: $0 generic find <token>\n"
				else
					token=$3

					response=$(echo "GENERIC FIND $token" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"

					if [[ $response == "TIMEOUT" ]]; then
						exit 2
					elif [[ $response == "ADDED" ]]; then
						exit 0
					else
						exit 1
					fi
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar generico.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Faltando parametro(s).\nSintaxe: $0 generic drop sender\n"
				else
					sender=$3

					response=$(echo "GENERIC DROP $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"

					if [[ $response == "TIMEOUT" ]]; then
						exit 2
					elif [[ $response == "OK" ]]; then
						exit 0
					else
						exit 1
					fi
				fi
			;;
			'show')
				# Parâmetros de entrada:
				#    1: ALL: lista os reversos genericos (opcional)
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar generico.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Faltando parametro(s).\nSintaxe: $0 generic show [all]\n"
				else
					if [ "$3" == "all" ]; then
						response=$(echo "GENERIC SHOW ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo "GENERIC SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"

					if [[ $response == "TIMEOUT" ]]; then
						exit 2
					elif [[ $response == "OK" ]]; then
						exit 0
					else
						exit 1
					fi
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 generic add recipient\n    $0 generic drop recipient\n    $0 generic show [all]\n"
			;;
		esac
	;;
	'white')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser bloqueado, com endereço completo.
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 white add recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"WHITE ADD $recipient" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'sender')
				# Parâmetros de entrada:
				#
				#    1. sender: o remetente que deve ser liberado, com endereço completo.
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 white sender recipient\n"
				else
					sender=$3

					response=$(echo "WHITE SENDER $sender" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"

					if [[ $response == "TIMEOUT" ]]; then
						exit 2
					elif [[ $response == "ADDED "* ]]; then
						exit 0
					elif [[ $response == "ALREADY "* ]]; then
						exit 0
					else
						exit 1
					fi
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser desbloqueado, com endereço completo.
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 white drop recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"WHITE DROP $recipient" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada: nenhum.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 white show\n"
				else
					response=$(echo $OTP_CODE"WHITE SHOW" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 white add recipient\n    $0 white sender recipient\n    $0 white drop recipient\n    $0 white show\n"
			;;
		esac
	;;
	'superwhite')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser bloqueado, com endereço completo.
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superwhite add recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"WHITE ADD $recipient" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser desbloqueado, com endereço completo.
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superwhite drop recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"WHITE DROP $recipient" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada: nenhum.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar bloqueio.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 superwhite show [all]\n"
				else
					if [ "$3" == "all" ]; then
						response=$(echo $OTP_CODE"WHITE SHOW ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"WHITE SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 superwhite add recipient\n    $0 superwhite drop recipient\n    $0 superwhite show [all]\n"
			;;
		esac
	;;
	'client')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. cidr: chave primária - endereço do host de acesso.
				#    2. domain: organizador do cadastro
				#	 3. option: opções de acesso -> NONE, SPFBL ou DNSBL
				#    4. email: [opcional] e-mail do cliente
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "5" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 client add cidr domain option [email]\n"
				else
					cidr=$3
					domain=$4
					option=$5
					email=""

					if [ -n "$6" ]; then
						email=$6
					fi
					
					response=$(echo $OTP_CODE"CLIENT ADD $cidr $domain $option $email" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'set')
				# Parâmetros de entrada:
				#
				#    1. cidr: chave primária - endereço do host de acesso.
				#    2. domain: organizador do cadastro
				#	 3. option: opções de acesso -> NONE, SPFBL ou DNSBL
				#    4. email: [opcional] e-mail do cliente
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "5" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 client set cidr domain option [email]\n"
				else
					cidr=$3
					domain=$4
					option=$5
					email=""

					if [ -n "$6" ]; then
						email=$6
					fi
					
					response=$(echo $OTP_CODE"CLIENT SET $cidr $domain $option $email" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. cidr: chave primária - endereço do host de acesso.
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 client drop cidr\n"
				else
					cidr=$3

					response=$(echo $OTP_CODE"CLIENT DROP $cidr" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 client show\n"
				else

					response=$(echo $OTP_CODE"CLIENT SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 client add cidr domain option [email] \n    $0 client set cidr domain option [email] \n    $0 client drop cidr\n    $0 client show\n"
			;;
		esac
	;;
	'user')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. email: E-mail do usuário.
				#    2. nome: Nome do usuário.
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adiciona.
				#    2: timeout de conexão.

				if [ $# -lt "4" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 user add email nome\n"
				else
					email=$3
					nome="${@:4}"

					response=$(echo $OTP_CODE"USER ADD $email $nome" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. email: E-mail do usuário.
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 user drop email\n"
				else
					email=$3

					response=$(echo $OTP_CODE"USER DROP $email" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')

				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.
				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 user show\n"
				else
					response=$(echo $OTP_CODE"USER SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 user add email nome\n    $0 user drop email\n    $0 user show\n"
			;;
		esac
	;;
	'peer')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#    2. email: E-mail do administrador.
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer add host [email]\n"
				else
					host=$3

					if [ -f "$4" ]; then
						email=$4
						response=$(echo $OTP_CODE"PEER ADD $host $email" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER ADD $host" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#
				# Códigos de saída:
				#
				#    0: removido com sucesso.
				#    1: erro ao tentar remover.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer drop { host | all }\n"
				else
					host=$3

					if [ "$host" == "all" ]; then
						response=$(echo $OTP_CODE"PEER DROP ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER DROP $host" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')

				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer show [host]\n"
				else

					if [ -f "$3" ]; then
						host=$3
						response=$(echo $OTP_CODE"PEER SHOW $host" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'set')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#    2. send: Opções para envio (##??##).
				#    3. receive: Opções para recebimento (##??##).
				#
				# Códigos de saída:
				#
				#    0: setado com sucesso.
				#    1: erro ao tentar setar opções.
				#    2: timeout de conexão.

				if [ $# -lt "5" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer set host send receive\n"
				else
					host=$3
					send=$4
					receive=$5

					response=$(echo $OTP_CODE"PEER SET $host $send $receive" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'ping')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#
				# Códigos de saída:
				#
				#    0: executado com sucesso.
				#    1: erro ao tentar executar.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer ping host\n"
				else
					host=$3

					response=$(echo $OTP_CODE"PEER PING $host" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'send')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#
				# Códigos de saída:
				#
				#    0: executado com sucesso.
				#    1: erro ao tentar executar.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 peer send host\n"
				else
					host=$3

					response=$(echo $OTP_CODE"PEER SEND $host" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 peer add host [email]\n    $0 peer drop { host | all }\n    $0 peer show [host]\n    $0 peer set host send receive\n    $0 peer ping host\n    $0 peer send host\n"
			;;
		esac
	;;
	'retention')
		case $2 in
			'show')
				# Parâmetros de entrada:
				#
				#    1. host: Endereço do peer.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.
				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 retention show { host | all }\n"
				else
					host=$3

					if [ "$host" == "all" ]; then
						response=$(echo $OTP_CODE"PEER RETENTION SHOW ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER RETENTION SHOW $host" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'release')
				# Parâmetros de entrada:
				#
				#    1. sender: Bloqueio recebido do peer.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.
				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 retention release { sender | all }\n"
				else
					sender=$3

					if [ "$sender" == "all" ]; then
						response=$(echo $OTP_CODE"PEER RETENTION RELEASE ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER RETENTION RELEASE $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'reject')
				# Parâmetros de entrada:
				#
				#    1. sender: Bloqueio recebido do peer.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar.
				#    2: timeout de conexão.
				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 retention reject { sender | all }\n"
				else
					sender=$3

					if [ "$sender" == "all" ]; then
						response=$(echo $OTP_CODE"PEER RETENTION REJECT ALL" | nc $IP_SERVIDOR $PORTA_ADMIN)
					else
						response=$(echo $OTP_CODE"PEER RETENTION REJECT $sender" | nc $IP_SERVIDOR $PORTA_ADMIN)
					fi

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 retention show { host | all }\n    $0 retention release { sender | all }\n    $0 retention reject { sender | all }\n"
			;;
		esac
	;;
	'reputation')
		# Parâmetros de entrada: nenhum
		#
		# Códigos de saída:
		#
		#    0: listado com sucesso.
		#    1: lista vazia.
		#    2: timeout de conexão.
		if [[ $2 == "cidr" ]]; then
			response=$(echo $OTP_CODE"REPUTATION CIDR" | nc $IP_SERVIDOR $PORTA_ADMIN)
		else
			response=$(echo $OTP_CODE"REPUTATION" | nc $IP_SERVIDOR $PORTA_ADMIN)
		fi
		
		if [[ $response == "" ]]; then
			response="TIMEOUT"
		fi

		echo "$response"
	;;
	'clear')
		# Parâmetros de entrada:
		#
		#    1. hostname: o nome do host cujas denúncias devem ser limpadas.
		#
		#
		# Códigos de saída:
		#
		#    0: limpado com sucesso.
		#    1: registro não encontrado em cache.
		#    2: erro ao processar atualização.
		#    3: timeout de conexão.
		if [ $# -lt "2" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 superclear hostname\n"
		else
			hostname=$2

			response=$(echo $OTP_CODE"CLEAR $hostname" | nc $IP_SERVIDOR $PORTA_ADMIN)

			if [[ $response == "" ]]; then
				response="TIMEOUT"
			fi

			echo "$response"
		fi
	;;
	'refresh')
		# Parâmetros de entrada:
		#
		#    1. hostname: o nome do host cujo registro SPF que deve ser atualizado.
		#
		#
		# Códigos de saída:
		#
		#    0: atualizado com sucesso.
		#    1: registro não encontrado em cache.
		#    2: erro ao processar atualização.
		#    3: timeout de conexão.

		if [ $# -lt "2" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 refresh hostname\n"
		else
			hostname=$2

			response=$(echo $OTP_CODE"REFRESH $hostname" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

			if [[ $response == "" ]]; then
				response="TIMEOUT"
			fi

			echo "$response"
		fi
	;;
	'analise')
		# Parâmetros de entrada:
		#
		#    1. IP: o IP a ser analisado.
		#
		#
		# Códigos de saída:
		#
		#    0: atualizado com sucesso.
		#    1: registro não encontrado em cache.
		#    2: erro ao processar atualização.
		#    3: timeout de conexão.
		case $2 in
			'show')
				response=$(echo $OTP_CODE"ANALISE SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)
				
				if [[ $response == "" ]]; then
					response="TIMEOUT"
				fi

				echo "$response"
			;;
			'dump')
				response=$(echo $OTP_CODE"ANALISE DUMP $3" | nc $IP_SERVIDOR $PORTA_ADMIN)
				
				if [[ $response == "" ]]; then
					response="TIMEOUT"
				fi

				echo "$response"
			;;
			'drop')

				response=$(echo $OTP_CODE"ANALISE DROP $3" | nc $IP_SERVIDOR $PORTA_ADMIN)

				if [[ $response == "" ]]; then
					response="TIMEOUT"
				fi

				echo "$response"
			;;
			[0-9]*)
				ip=$2

				response=$(echo $OTP_CODE"ANALISE $ip" | nc $IP_SERVIDOR $PORTA_ADMIN)

				if [[ $response == "" ]]; then
					response="TIMEOUT"
				fi

				echo "$response"
			;;
			*)
				head
				printf "Invalid Parameters. Syntax: $0 analise <ip> or {show | dump | drop} \n"
			;;
		esac
	;;
	'check')
		# Parâmetros de entrada:
		#
		#    1. IP: o IPv4 ou IPv6 do host de origem.
		#    2. email: o email do remetente.
		#    3. HELO: o HELO passado pelo host de origem.
		#
		# Saídas com qualificadores e os tokens com suas probabilidades:
		#
		#    <quaificador>\n
		#    <token> <probabilidade>\n
		#    <token> <probabilidade>\n
		#    <token> <probabilidade>\n
		#    ...
		#
		# Códigos de saída:
		#
		#    0: não especificado.
		#    1: qualificador NEUTRAL.
		#    2: qualificador PASS.
		#    3: qualificador FAIL.
		#    4: qualificador SOFTFAIL.
		#    5: qualificador NONE.
		#    6: erro temporário.
		#    7: erro permanente.
		#    8: listado em lista negra.
		#    9: timeout de conexão.
		#    10: domínio inexistente.
		#    11: parâmetros inválidos.

		if [ $# -lt "4" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 check ip email helo\n"
		else
			ip=$2
			email=$3
			helo=$4

			qualifier=$(echo $OTP_CODE"CHECK '$ip' '$email' '$helo'" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

			if [[ $qualifier == "" ]]; then
				qualifier="TIMEOUT"
			fi

			echo "$qualifier"

			if [[ $qualifier == "TIMEOUT" ]]; then
				exit 9
			elif [[ $qualifier == "NXDOMAIN" ]]; then
				exit 10
			elif [[ $qualifier == "LISTED"* ]]; then
				exit 8
			elif [[ $qualifier == "INVALID" ]]; then
				exit 11
			elif [[ $qualifier == "ERROR: HOST NOT FOUND" ]]; then
				exit 6
			elif [[ $qualifier == "ERROR: QUERY" ]]; then
				exit 11
			elif [[ $qualifier == "ERROR: "* ]]; then
				exit 7
			elif [[ $qualifier == "NONE"* ]]; then
				exit 5
			elif [[ $qualifier == "PASS"* ]]; then
				exit 2
			elif [[ $qualifier == "FAIL" ]]; then
				exit 3
			elif [[ $qualifier == "SOFTFAIL"* ]]; then
				exit 4
			elif [[ $qualifier == "NEUTRAL"* ]]; then
				exit 1
			else
				exit 0
			fi
		fi
	;;
	'spam')
		# Este comando procura e extrai o ticket de consulta SPFBL de uma mensagem de e-mail se o parâmetro for um arquivo.
		#
		# Com posse do ticket, ele envia a reclamação ao serviço SPFBL para contabilização de reclamação.
		#
		# Parâmetros de entrada:
		#  1. o arquivo de e-mail com o ticket ou o ticket sozinho.
		#
		# Códigos de saída:
		#  0. Ticket enviado com sucesso.
		#  1. Arquivo inexistente.
		#  2. Arquivo não contém ticket.
		#  3. Erro no envio do ticket.
		#  4. Timeout no envio do ticket.
		#  5. Parâmetro inválido.
		#  6. Ticket inválido.

		if [ $# -lt "2" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 spam [ticketid or file]\n"
		else
                        if [[ $2 =~ ^http://.+/spam/[a-zA-Z0-9%]{44,1024}$ ]]; then
                                # O parâmentro é uma URL de denúncia SPFBL.
                                url=$2
			elif [[ $2 =~ ^[a-zA-Z0-9/+=]{44,1024}$ ]]; then
				# O parâmentro é um ticket SPFBL.
				ticket=$2
			elif [ -f "$2" ]; then
				# O parâmetro é um arquivo.
				file=$2

				if [ -e "$file" ]; then
					# Extrai o ticket incorporado no arquivo.
					ticket=$(grep -Pom 1 "^Received-SPFBL: (PASS|SOFTFAIL|NEUTRAL|NONE) \K([0-9a-zA-Z\+/=]+)$" $file)

					if [ $? -gt 0 ]; then

						# Extrai o ticket incorporado no arquivo.
						url=$(grep -Pom 1 "^Received-SPFBL: (PASS|SOFTFAIL|NEUTRAL|NONE) \K(http://.+/spam/[0-9a-zA-Z\+/=]+)$" $file)

						if [ $? -gt 0 ]; then
							echo "Nenhum ticket SPFBL foi encontrado na mensagem."
							exit 2
						fi
					fi
				else
					echo "O arquivo não existe."
					exit 1
				fi
			else
				echo "O parâmetro passado não corresponde a um arquivo nem a um ticket."
				exit 5
			fi

			if [[ -z $url ]]; then
				if [[ -z $ticket ]]; then
					echo "Ticket SPFBL inválido."
					exit 6
				else
					# Registra reclamação SPFBL.
					resposta=$(echo $OTP_CODE"SPAM $ticket" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $resposta == "" ]]; then
						echo "A reclamação SPFBL não foi enviada por timeout."
						exit 4
					elif [[ $resposta == "OK"* ]]; then
						echo "Reclamação SPFBL enviada com sucesso."
						exit 0
					elif [[ $resposta == "ERROR: DECRYPTION" ]]; then
						echo "Ticket SPFBL inválido."
						exit 6
					else
						echo "A reclamação SPFBL não foi enviada: $resposta"
						exit 3
					fi
				fi
			else
				# Registra reclamação SPFBL via HTTP.
                                resposta=$(curl -X PUT -s -m 3 $url)
				if [[ $? == "28" ]]; then
					echo "A reclamação SPFBL não foi enviada por timeout."
					exit 4
				elif [[ $resposta == "OK"* ]]; then
					echo "Reclamação SPFBL enviada com sucesso."
					exit 0
				elif [[ $resposta == "ERROR: DECRYPTION" ]]; then
					echo "Ticket SPFBL inválido."
					exit 6
				else
					echo "A reclamação SPFBL não foi enviada: $resposta"
					exit 3
				fi
			fi
		fi
	;;
	'ham')
		# Este comando procura e extrai o ticket de consulta SPFBL de uma mensagem de e-mail se o parâmetro for um arquivo.
		#
		# Com posse do ticket, ele solicita a revogação da reclamação ao serviço SPFBL.
		#
		# Parâmetros de entrada:
		#  1. o arquivo de e-mail com o ticket ou o ticket sozinho.
		#
		# Códigos de saída:
		#  0. Reclamação revogada com sucesso.
		#  1. Arquivo inexistente.
		#  2. Arquivo não contém ticket.
		#  3. Erro no envio do ticket.
		#  4. Timeout no envio do ticket.
		#  5. Parâmetro inválido.
		#  6. Ticket inválido.

		if [ $# -lt "2" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 ham [ticketid or file]\n"
		else
			if [[ $2 =~ ^http://.+/spam/[a-zA-Z0-9%]{44,1024}$ ]]; then
	                        # O parâmentro é uma URL de denúncia SPFBL.
	                        url=$2
			elif [[ $2 =~ ^[a-zA-Z0-9/+=]{44,1024}$ ]]; then
				# O parâmentro é um ticket SPFBL.
				ticket=$2
			elif [ -f "$2" ]; then
				# O parâmetro é um arquivo.
				file=$2

				if [ -e "$file" ]; then
					# Extrai o ticket incorporado no arquivo.
					ticket=$(grep -Pom 1 "^Received-SPFBL: (PASS|SOFTFAIL|NEUTRAL|NONE) \K([0-9a-zA-Z\+/=]+)$" $file)

					if [ $? -gt 0 ]; then

						# Extrai o ticket incorporado no arquivo.
						url=$(grep -Pom 1 "^Received-SPFBL: (PASS|SOFTFAIL|NEUTRAL|NONE) \K(http://.+/spam/[0-9a-zA-Z\+/=]+)$" $file)

						if [ $? -gt 0 ]; then
							echo "Nenhum ticket SPFBL foi encontrado na mensagem."
							exit 2
						fi
					fi
				else
					echo "O arquivo não existe."
					exit 1
				fi
			else
				echo "O parâmetro passado não corresponde a um arquivo nem a um ticket."
				exit 5
			fi

			if [[ -z $url ]]; then
				if [[ -z $ticket ]]; then
					echo "Ticket SPFBL inválido."
					exit 6
				else
					# Registra reclamação SPFBL.
					resposta=$(echo $OTP_CODE"HAM $ticket" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $resposta == "" ]]; then
						echo "A revogação SPFBL não foi enviada por timeout."
						exit 4
					elif [[ $resposta == "OK"* ]]; then
						echo "Revogação SPFBL enviada com sucesso."
						exit 0
					elif [[ $resposta == "ERROR: DECRYPTION" ]]; then
						echo "Ticket SPFBL inválido."
						exit 6
					else
						echo "A revogação SPFBL não foi enviada: $resposta"
						exit 3
					fi
				fi
			else
				# Registra reclamação SPFBL via HTTP.
				spamURL=/spam/
                                hamURL=/ham/
				url=${url/$spamURL/$hamURL}
                                resposta=$(curl -X PUT -s -m 3 $url)
				if [[ $? == "28" ]]; then
					echo "A revogação SPFBL não foi enviada por timeout."
					exit 4
				elif [[ $resposta == "OK"* ]]; then
					echo "Revogação SPFBL enviada com sucesso."
					exit 0
				elif [[ $resposta == "ERROR: DECRYPTION" ]]; then
					echo "Ticket SPFBL inválido."
					exit 6
				else
					echo "A revogação SPFBL não foi enviada: $resposta"
					exit 3
				fi

			fi
		fi
	;;
	'query')
		# A saída deste programa deve ser incorporada ao cabeçalho
		# Received-SPFBL da mensagem de e-mail que gerou a consulta.
		#
		# Exemplo:
		#
		#    Received-SPFBL: PASS urNq9eFn65wKwDFGNsqCNYmywnlWmmilhZw5jdtvOr5jYk6mgkiWgQC1w696wT3ylP3r8qZnhOjwntTt5mCAuw==
		#
		# A informação que precede o qualificador é o ticket da consulta SPFBL.
		# Com o ticket da consulta, é possível realizar uma reclamação ao serviço SPFBL,
		# onde esta reclamação vai contabilizar a reclamação nos contadores do responsável pelo envio da mensagem.
		# O ticket da consulta só é gerado nas saídas cujos qualificadores sejam: PASS, SOFTFAIL, NEUTRAL e NONE.
		#
		# Parâmetros de entrada:
		#
		#    1. IP: o IPv4 ou IPv6 do host de origem.
		#    2. email: o email do remetente (opcional).
		#    3. HELO: o HELO passado pelo host de origem.
		#    4. recipient: o destinátario da mensagem (opcional se não utilizar spamtrap).
		#
		# Saídas com qualificadores e as ações:
		#
		#    PASS <ticket>: permitir o recebimento da mensagem.
		#    FAIL: rejeitar o recebimento da mensagem e informar à origem o descumprimento do SPF.
		#    SOFTFAIL <ticket>: permitir o recebimento da mensagem mas marcar como suspeita.
		#    NEUTRAL <ticket>: permitir o recebimento da mensagem.
		#    NONE <ticket>: permitir o recebimento da mensagem.
		#    LISTED: atrasar o recebimento da mensagem e informar à origem a listagem em blacklist por sete dias.
		#    BLOCKED: rejeitar o recebimento da mensagem e informar à origem o bloqueio permanente.
		#    FLAG: aceita o recebimento e redirecione a mensagem para a pasta SPAM.
		#    SPAMTRAP: discaratar silenciosamente a mensagem e informar à origem que a mensagem foi recebida com sucesso.
		#    GREYLIST: atrasar a mensagem informando à origem ele está em greylisting.
		#    NXDOMAIN: o domínio do remetente é inexistente.
		#    INVALID: o endereço do remetente é inválido.
		#
		# Códigos de saída:
		#
		#    0: não especificado.
		#    1: qualificador NEUTRAL.
		#    2: qualificador PASS.
		#    3: qualificador FAIL.
		#    4: qualificador SOFTFAIL.
		#    5: qualificador NONE.
		#    6: erro temporário.
		#    7: erro permanente.
		#    8: listado em lista negra.
		#    9: timeout de conexão.
		#    10: bloqueado permanentemente.
		#    11: spamtrap.
		#    12: greylisting.
		#    13: domínio inexistente.
		#    14: IP ou remetente inválido.
		#    15: mensagem originada de uma rede local.
		#    16: mensagem marcada como SPAM.

		if [ $# -lt "5" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 query ip email helo recipient\n"
		else
			ip=$2
			email=$3
			helo=$4
			recipient=$5

			qualifier=$(echo $OTP_CODE"SPF '$ip' '$email' '$helo' '$recipient'" | nc -w $QUERY_TIMEOUT $IP_SERVIDOR $PORTA_SERVIDOR)

			if [[ $qualifier == "" ]]; then
				qualifier="TIMEOUT"
			fi

			echo "$qualifier"

			if [[ $qualifier == "TIMEOUT" ]]; then
				exit 9
			elif [[ $qualifier == "NXDOMAIN" ]]; then
				exit 13
			elif [[ $qualifier == "GREYLIST" ]]; then
				exit 12
			elif [[ $qualifier == "INVALID" ]]; then
				exit 14
			elif [[ $qualifier == "LAN" ]]; then
				exit 15
			elif [[ $qualifier == "FLAG" ]]; then
				exit 16
			elif [[ $qualifier == "SPAMTRAP" ]]; then
				exit 11
			elif [[ $qualifier == "BLOCKED"* ]]; then
				exit 10
			elif [[ $qualifier == "LISTED"* ]]; then
				exit 8
			elif [[ $qualifier == "ERROR: HOST NOT FOUND" ]]; then
				exit 6
			elif [[ $qualifier == "ERROR: "* ]]; then
				exit 7
			elif [[ $qualifier == "NONE "* ]]; then
				exit 5
			elif [[ $qualifier == "PASS "* ]]; then
				exit 2
			elif [[ $qualifier == "FAIL "* ]]; then
			        # Retornou FAIL com ticket então
			        # significa que está em whitelist.
			        # Retornar como se fosse SOFTFAIL.
				exit 4
			elif [[ $qualifier == "FAIL" ]]; then
				exit 3
			elif [[ $qualifier == "SOFTFAIL "* ]]; then
				exit 4
			elif [[ $qualifier == "NEUTRAL "* ]]; then
				exit 1
			else
				exit 0
			fi
		fi
	;;
	'trap')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser considerado armadilha.
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar armadilha.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 trap add recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"TRAP ADD $recipient" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que deve ser considerado armadilha.
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar armadilha.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 trap drop recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"TRAP DROP $recipient" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada: nenhum.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar armadilhas.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 trap show\n"
				else
					response=$(echo $OTP_CODE"TRAP SHOW" | nc $IP_SERVIDOR $PORTA_SERVIDOR)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 trap add recipient\n    $0 trap drop recipient\n    $0 trap show\n"
			;;
		esac
	;;
	'noreply')
		case $2 in
			'add')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que o SPFBL não deve enviar mensagem de e-mail.
				#
				#
				# Códigos de saída:
				#
				#    0: adicionado com sucesso.
				#    1: erro ao tentar adicionar endereço.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 noreply add recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"NOREPLY ADD $recipient" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'drop')
				# Parâmetros de entrada:
				#
				#    1. recipient: o destinatário que o SPFBL não deve enviar mensagem de e-mail.
				#
				#
				# Códigos de saída:
				#
				#    0: desbloqueado com sucesso.
				#    1: erro ao tentar adicionar endereço.
				#    2: timeout de conexão.

				if [ $# -lt "3" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 noreply drop recipient\n"
				else
					recipient=$3

					response=$(echo $OTP_CODE"NOREPLY DROP $recipient" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			'show')
				# Parâmetros de entrada: nenhum.
				#
				# Códigos de saída:
				#
				#    0: visualizado com sucesso.
				#    1: erro ao tentar visualizar endereços.
				#    2: timeout de conexão.

				if [ $# -lt "2" ]; then
					head
					printf "Invalid Parameters. Syntax: $0 noreply show\n"
				else
					response=$(echo $OTP_CODE"NOREPLY SHOW" | nc $IP_SERVIDOR $PORTA_ADMIN)

					if [[ $response == "" ]]; then
						response="TIMEOUT"
					fi

					echo "$response"
				fi
			;;
			*)
				head
				printf "Syntax:\n    $0 noreply add recipient\n    $0 noreply drop recipient\n    $0 noreply show\n"
			;;
		esac
	;;
	'dump')
		# Parâmetros de entrada: nenhum.
		#
		# Códigos de saída: nenhum.

		echo $OTP_CODE"DUMP" | nc $IP_SERVIDOR $PORTA_ADMIN > $DUMP_PATH/spfbl.dump.$(date "+%Y-%m-%d_%H-%M")
		if [ -f $DUMP_PATH/spfbl.dump.$(date "+%Y-%m-%d_%H-%M") ]; then
			echo "Dump saved as $DUMP_PATH/spfbl.dump.$(date "+%Y-%m-%d_%H-%M")"
		else
			echo "File $DUMP_PATH/spfbl.dump.$(date "+%Y-%m-%d_%H-%M") not found."
		fi
	;;
	'load')
		# Parâmetros de entrada: nenhum.
		#
		# Códigos de saída: nenhum.

		if [ $# -lt "2" ]; then
			head
			printf "Invalid Parameters. Syntax: $0 load path\n"
		else
			file=$1
			if [ -f $file ]; then
				for line in `cat $file`; do
					echo -n "Adding $line ... "
					echo $OTP_CODE"$line" | nc $IP_SERVIDOR $PORTA_ADMIN
				done
			else
				echo "File not found."
			fi
		fi
	;;
	*)
		head
		printf "Help\n\n"
		printf "User Commands:\n"
		printf "    $0 version\n"
		printf "    $0 block { add sender | drop sender | show [all] | find }\n"
		printf "    $0 white { add sender | drop sender | show | sender }\n"
		printf "    $0 reputation\n"
		printf "    $0 clear hostname\n"
		printf "    $0 refresh hostname\n"
		printf "    $0 check ip email helo\n"
		printf "    $0 spam ticketid/file\n"
		printf "    $0 ham ticketid/file\n"
		printf "    $0 query ip email helo recipient\n"
		printf "    $0 trap { add recipient | drop recipient | show }\n"
		printf "    $0 noreply { add recipient | drop recipient | show }\n"
		printf "\n"
		printf "Admin Commands:\n"
		printf "    $0 shutdown\n"
		printf "    $0 store\n"
		printf "    $0 superclear hostname\n"
		printf "    $0 tld { add tld | drop tld | show }\n"
		printf "    $0 peer { add host [email] | drop { host | all } | show [host] | set host send receive | ping host | send host }\n"
		printf "    $0 retention { show [host] | release { sender | all } | reject { sender | all } }\n"
		printf "    $0 provider { add sender | drop sender | show }\n"
		printf "    $0 ignore { add sender | drop sender | show }\n"
		printf "    $0 client { add/set cidr domain option [email] | drop cidr | show }\n"
		printf "    $0 user { add email nome | drop email | show }\n"
		printf "    $0 superblock { add sender | drop sender | show [all] | split | overlap }\n"
		printf "    $0 superwhite { add sender | drop sender | show [all] }\n"
		printf "    $0 analise <ip> or { show | dump | drop }\n"
		printf "    $0 dump\n"
		printf "    $0 load path\n"
		printf "\n"
	;;
esac

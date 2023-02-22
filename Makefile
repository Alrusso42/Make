SRC_FILES    = a b c d
SRC_DIR        = src
#INC_FILES    = core
INC_DIR        = inc
ARCHIVE_DIR := archive
$(shell mkdir -p $(ARCHIVE_DIR))

ifeq ($(SRC_OUT .cpp), )
	CC = c++
else
	CC = gcc
endif

#SRC_OUT        = $(foreach f, $(SRC_FILES), $(wildcard $(f)*.c*))
#SRC_IN        = $(foreach f, $(SRC_FILES), $(wildcard $(SRC_DIR)/$(f)*.c*))
#INC_OUT        = $(foreach f, $(INC_FILES), $(wildcard $(f)*.h*))
#INC_IN        = $(foreach f, $(INC_FILES), $(wildcard $(INC_DIR)/$(f)*.h*))

 #Fonctionne mais DANGER DE MORT ☠️
SRC_IN     = $(wildcard $(SRC_DIR)/*.c*)
SRC_OUT    = $(wildcard *.c*)
INC_IN     = $(wildcard $(INC_DIR)/*.h*)
INC_OUT    = $(wildcard *.h*)

OBJ_DIR        = bin
OBJ_OUT        = $(filter $(wildcard *.c*), $(SRC_OUT))
OBJ_IN        = $(filter $(wildcard $(SRC_DIR)/*.c*), $(SRC_IN))
OBJ            =    $(patsubst %.cpp, %.o, \
                $(patsubst %.c, %.o, \
                $(OBJ_OUT) $(OBJ_IN)))

CURRENT_FOLDER = $(shell basename "$(shell pwd)") #Récupère le nom du dossier courant pour attribuer son nom à l'executable
NAME = $(CURRENT_FOLDER)

#LIBS = -L libft -l ft => Liaison à une librairie
FLAGS = -Wall -Werror -Wextra -g3
CPPFLAGS = -Wall -Werror -Wextra -g3 -std=c++98
DANGER = -fsanitize=address
NOERR			= || true
STOP			= && false
SILENT = > /dev/null 2>&1 | true #Permet de renvoyer les messages d'erreur dans le néant
CONTINUE		= $(SILENT) $(NOERR)

all: $(NAME)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@c++ $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@gcc $(FLAGS) -c $< -o $@

.cpp.o:
	@c++ $(CPPFLAGS) -c $< -o $@
	@printf "$(CMP_WORK_CT)" # Imprime le message
	@$(eval CMP_COUNT = $(shell expr $(CMP_COUNT) + 1)) # Incremente le compteur

.c.o:
	@gcc $(FLAGS) -c $< -o $@
	@printf "$(CMP_WORK_CT)" # Imprime le message
	@$(eval CMP_COUNT = $(shell expr $(CMP_COUNT) + 1)) # Incremente le compteur

$(NAME): $(OBJ)
	@$(CC) $(LIBS) $(DANGER) $(OBJ) -o $@
	@$(MAKE) pack

debug:
	@echo $(OBJ_OUT)
	@echo $(OBJ_IN)
	@echo $(OBJ)

pack:
	@mkdir -p $(SRC_DIR) $(INC_DIR) $(OBJ_DIR)
	@mv $(SRC_OUT) $(SRC_DIR) $(SILENT)
	@mv $(INC_OUT) $(INC_DIR) $(SILENT)
	@mv $(OBJ) $(OBJ_DIR) $(SILENT)
	@printf "$(PKG_SUCCESS)"

unpack:
	@if [ -d ./src ]; \
	then \
	    mv $(SRC_IN) . && rm -R ./src && printf "$(CLR_PACKAGE)"; \
	else \
	    printf "$(CLR_PKGFAIL)"; \
	fi
	@if [ -d ./inc ]; \
	then \
	    mv $(INC_IN) . && rm -R ./inc && printf "$(CLR_PACKAGE)"; \
	else \
	    printf "$(CLR_PKGFAIL)"; \
	fi
	@if [ -d ./bin ]; \
	then \
	    mv $(OBJ_DIR)/$(OBJ) . && rm -R ./bin && printf "$(CLR_PACKAGE)"; \
	else \
	    printf "$(CLR_PACKAGE)"; \
	fi

clean:
	@if [ -d ./bin ]; \
	then \
	    rm -Rf ./bin && printf "$(CLR_SUCCESS)"; \
	else \
	    printf "$(CLR_FAILURE)"; \
	fi


fclean: clean unpack
	@if [ -f $(NAME) ]; \
		then rm -Rf $(NAME) \
		&& printf "$(CLR_EXECUTE)"; \
		else printf "$(CLR_EXEFAIL)"; \
	fi

re: fclean
	@$(MAKE) all

#zip:
#	@if [ ! -d "archive" ]; then mkdir archive; fi
#	@zip --quiet -r "archive/archive$(CURRENT_FOLDER).zip" . &> /dev/null 2>&1
#	@printf "$(CMP_WORK_ZP)" # Imprime le message
#	@$(eval CMP_COUNT_ZP = $(shell expr $(CMP_COUNT_ZP) + 1)) # Incremente le compteur
#	@printf "$(ZIP_SUCCESS)";
# Récupère la version actuelle du fichier de version (s'il existe) ou initialise à 1.
VERSION := $(shell if [ -f version.txt ]; then echo $$(($(shell cat version.txt) + 1)); else echo 1; fi)

# Enregistre la version actuelle dans le fichier de version.
version:
	@echo "$(VERSION)" > version.txt

# Crée une archive zip avec le nom de fichier formaté avec la version actuelle.
.PHONY: zip
zip: version
	@zip -r "$(ARCHIVE_DIR)/$(subst ",_,$(subst ',_,$(DIRNAME)))_archive_v$(VERSION).zip" .

# Règle phony pour nettoyer les fichiers temporaires.
czip:
	@if [ -d "archive" ]; then rm -rf archive; fi
	@rm -f version.txt
	@printf "$(ZIP_SUCCESS)";

#PROGRESS BAR COMPILING

CMP_WORK_CT	= $(MSG_WORK) [$(CMP_COUNT) / $(CMP_TOTAL)] Compiling $@ ... $(MSG_NRET)
CMP_TOTAL	= $(shell awk -F' ' '{printf NF}' <<< "$(SRC)")
CMP_COUNT	= 0
#PROGRESS BAR ZIPPING
CMP_WORK_ZP	= $(MSG_WORK) [$(CMP_COUNT_ZP) / $(CMP_TOTAL_ZP)] Compressing $@ ... $(MSG_NRET)
CMP_TOTAL_ZP	= $(shell awk -F' ' '{printf NF}' <<< "$(SRC)")
CMP_COUNT_ZP	= 0
#==--------------------------------------==#
# *                                      * #
#             DISPLAY MESSAGES             #
# *                                      * #
#==--------------------------------------==#

# If you wish to customize the display messages,
# feel free to modify below :)

#####   SYNTAX SEQUENCES   #####
ESC			= 
ICO_PROCESS	= ƒ
ICO_SUCCESS	= √
ICO_FAILURE	= ø
NEWLINE	= \n
BREAK	= \r
RED			= $(ESC)[0;31m
GRN			= $(ESC)[0;32m
YLW			= $(ESC)[0;33m
BLU			= $(ESC)[0;34m
DRK			= $(ESC)[0;2m
NUL			= $(ESC)[0m
END			= $(ESC)[0m$(NEWLINE)
BACK		= $(ESC)[2K$(BREAK)


#####   GENERAL COMBINAISONS   #####
MSG_WORK	= $(BACK)$(YLW)$(ICO_PROCESS)
MSG_GOOD	= $(BACK)$(GRN)$(ICO_SUCCESS)
MSG_ERROR	= $(BACK)$(RED)$(ICO_FAILURE)
MSG_NRET    = $(NUL)

#####   COMPILING MESSAGES   #####
CMP_NEEDING	= $(MSG_WORK) Compiling dependencies ... $(NUL)
CMP_WORKING	= $(MSG_WORK) Compiling $@ ... $(NUL)
CMP_SUCCESS	= $(MSG_GOOD) The programm $(NAME) has been compiled successfully! $(END)
CMP_FAILURE	= $(MSG_ERROR) The programm $(NAME) failed to compile! $(END)
PKG_SUCCESS = $(MSG_GOOD) The package is ready for export! $(END)
ZIP_SUCCESS = $(MSG_GOOD) The zip files is ready for export! $(END)

#####   CLEARING MESSAGES   #####
CLR_NEEDING	= $(MSG_WORK) Cleaning dependencies ... $(NUL)
CLR_WORKING	= $(MSG_WORK) Cleaning files ... $(NUL)
CLR_SUCCESS	= $(MSG_GOOD) Objects has been removed! $(END)
CLR_FAILURE	= $(MSG_ERROR) Objects couldn't be removed! $(END)
CLR_EXECUTE	= $(MSG_GOOD) Executable has been removed! $(END)
CLR_EXEFAIL	= $(MSG_ERROR) Executable couldn't be removed! $(END)
CLR_PACKAGE	= $(MSG_GOOD) Package has been removed! $(END)
CLR_PKGFAIL	= $(MSG_ERROR) Package couldn't be removed! $(END)
CLR_DEPENDS	= $(MSG_GOOD) Dependencies has been removed! $(END)
CLR_DEPFAIL	= $(MSG_ERROR) Dependencies couldn't be removed! $(END)
CLR_ZIP	= $(MSG_GOOD) Zip file has been removed! $(END)


.DEFAULT_GOAL = all #Permet de modifier la regle par default
.PHONY: all clean fclean pack unpack zip czip re version
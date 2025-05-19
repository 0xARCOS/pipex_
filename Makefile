NAME	= pipex
CC		= cc
CFLAGS	= -Wall -Wextra -Werror -g3 
RM		= rm -f

SRCS	= pipex.c child_cmd.c ft_split.c utils.c main.c
OBJS	= $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

clean:
	$(RM) $(OBJS)

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aarcos <aarcos@student.42.fr>              #+#  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025-05-16 14:49:32 by aarcos            #+#    #+#             */
/*   Updated: 2025-05-16 14:49:32 by aarcos           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

int main(int argc, char **argv, char **envp)
{
    if (argc != 5)
    {
        write(2, "Usage: ./pipex infile cmd1 cmd2 outfile", 40);
        return (1);
    }
    pipex(argv, envp);
    return (0);
}
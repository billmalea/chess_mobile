import 'package:flutter/material.dart';

class TournamentPage extends StatelessWidget {
  const TournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UpcomingTournaments();
  }
}

class UpcomingTournaments extends StatelessWidget {
  const UpcomingTournaments({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your data source to fetch upcoming tournaments
    List<Tournament> tournaments = getUpcomingTournaments();

    if (tournaments.isEmpty) {
      return const Center(
        child: Text('No upcoming tournaments available.'),
      );
    }

    return ListView.builder(
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tournaments[index].name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${tournaments[index].date}'),
              Text('Prize Money: \$${tournaments[index].prizeMoney}'),
              Text('Registration Fee: \$${tournaments[index].registrationFee}'),
              Text(
                  'Registration Deadline: ${tournaments[index].registrationDeadline}'),
            ],
          ),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RegistrationPage(tournament: tournaments[index]),
              ),
            );
          },
        );
      },
    );
  }

  // Replace this with your logic to fetch upcoming tournaments
  List<Tournament> getUpcomingTournaments() {
    // Simulate fetching upcoming tournaments from a data source
    return [
      Tournament(
          name: 'Tournament 1',
          date: '2023-11-10',
          prizeMoney: 1000,
          registrationFee: 50,
          registrationDeadline: '2023-11-05'),
      Tournament(
          name: 'Tournament 2',
          date: '2023-11-15',
          prizeMoney: 1500,
          registrationFee: 75,
          registrationDeadline: '2023-11-10'),
      Tournament(
          name: 'Tournament 3',
          date: '2023-11-20',
          prizeMoney: 800,
          registrationFee: 40,
          registrationDeadline: '2023-11-15'),
    ];
  }
}

class Tournament {
  final String name;
  final String date;
  final double prizeMoney;
  final double registrationFee;
  final String registrationDeadline;

  Tournament({
    required this.name,
    required this.date,
    required this.prizeMoney,
    required this.registrationFee,
    required this.registrationDeadline,
  });
}

class RegistrationPage extends StatelessWidget {
  final Tournament tournament;

  const RegistrationPage({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for ${tournament.name}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Implement the registration logic here
          },
          child: Text('Register for ${tournament.name}'),
        ),
      ),
    );
  }
}

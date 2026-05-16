namespace :outcome_signals do
  desc 'Print a local summary of product outcome signal quality'
  task summary: :environment do
    puts OutcomeSignals::Summary.new.lines
  end
end

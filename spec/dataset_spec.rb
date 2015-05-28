require 'spec_helper.rb'

describe Dataset do
  context 'creation' do
    before do
      x = (0..10).to_a
      y = x.map { |xx| Math.exp(-xx) }
      @data = [x, y]
    end

    it 'may be created with math function as data' do
      dataset = Dataset.new('sin(x)')
      expect(dataset.to_s).to eql('sin(x) ')
    end

    it 'may be created with datafile as data' do
      dataset = Dataset.new('spec/points.data')
      expect(dataset.to_s).to eql("'spec/points.data' ")
    end

    it 'may be created with some class with #to_points' do
      dataset = Dataset.new(@data)
      expect(dataset.data).to be_an_instance_of(Datablock)
      expect(dataset.to_s(Terminal.new)).to eql('$DATA1 ')
    end

    it 'may be created with clone of existing datablock as data' do
      datablock = Datablock.new(@data)
      dataset = Dataset.new(datablock)
      expect(dataset.data).to be_an_instance_of(Datablock)
      expect(datablock).to_not equal(dataset.data) # given datablock should be cloned
    end

    it 'may be created with existing stored in file datablock' do
      datablock = Datablock.new(@data, true)
      dataset = Dataset.new(datablock)
      expect(dataset.data).to be_an_instance_of(Datablock)
      # since given datablock's data stored in file, it should not be cloned
      expect(datablock).to equal(dataset.data)
      expect(dataset.to_s(Terminal.new)).to eql("#{datablock.name} ")
    end

    it 'may be created with given gnuplot options' do
      dataset = Dataset.new(@data, title: 'Dataset title', with: 'linespoints')
      expect(dataset.to_s(Terminal.new)).to eql("$DATA1 title 'Dataset title' with linespoints")
    end

    it 'may be created with special :file option' do
      # {:file => true} will force creation of stored in file datablock
      dataset = Dataset.new(@data, title: 'Dataset title', file: true)
      expect(dataset.data.name).to match(/tmp_data/)
      expect(dataset.to_s).to eql("#{dataset.data.name} title 'Dataset title'")
    end
  end

  context 'options handling' do
    before do
      @options = Hamster.hash(title: 'Gnuplot::Dataset', with: 'lines')
      @dataset = Dataset.new('sin(x)', @options)
    end

    it 'should allow to get option value by name' do
      @options.each { |key, value| expect(@dataset.send(key)).to eql(value) }
    end

    it 'should allow to safely set option value by name' do
      new_with = 'points'
      new_dataset = @dataset.with(new_with)
      expect(@dataset.with).to equal(@options[:with])
      expect(new_dataset.with).to equal(new_with)
    end

    it 'should allow to get all the options' do
      expect(@dataset.options).to eql(@options)
    end

    it 'should allow to safely set several options at once' do
      new_options = Hamster.hash(title: 'Some new title', with: 'lines', lt: 3)
      new_dataset = @dataset.options(new_options)
      @options.each { |key, value| expect(@dataset.send(key)).to eql(value) }
      new_options.each { |key, value| expect(new_dataset.send(key)).to eql(value) }
    end
  end
end
